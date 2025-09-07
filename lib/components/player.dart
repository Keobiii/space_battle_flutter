import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:space_battle/components/asteriod.dart';
import 'package:space_battle/components/bomb.dart';
import 'package:space_battle/components/explosion.dart';
import 'package:space_battle/components/laser.dart';
import 'package:space_battle/components/pickup.dart';
import 'package:space_battle/components/shield.dart';
import 'package:space_battle/my_game.dart';

class Player extends SpriteAnimationComponent with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks{
  bool _isShooting = true;
  final double _fireCooldown = 0.2;
  double _elapsedFireTime = 0.0;
  final Vector2 _keyboardMovement = Vector2.zero();
  bool _isDestroyed = false;
  final Random _random = Random();
  late Timer _explosionTimer;
  late Timer _laserPowerupTimer;
  Shield? activeShield;

  Player() {
    _explosionTimer =Timer(
      0.1, 
      onTick: _createRandomExplosion,
      repeat: true,
      autoStart: false
    );

    _laserPowerupTimer = Timer(
      10.0,
      autoStart: false
    );
  }

  @override
  FutureOr<void> onLoad() async{
    // TODO: implement onLoad
    // sprite = await game.loadSprite('player_blue_on0.png');

    animation = await _loadAnimation();

    // resize the player
    size *= 0.3;

    // hitbox for player
    add(RectangleHitbox.relative(
      Vector2(0.6, 0.9), 
      parentSize: size,
      anchor: Anchor.center
    ));

    return super.onLoad();
  }

  // update the position of the player
  @override
  void update(double dt) {
    // TODO: implement update

    if(_isDestroyed) {
      _explosionTimer.update(dt);
      return;
    }

    if (_laserPowerupTimer.isRunning()) {
      _laserPowerupTimer.update(dt);
    }

    // handle the movement of the player
    // base on the computer/device complexity using dt
    // position.y -= 200 * dt;

    // getting the joystick input
    // print(game.joystick.relativeDelta);

    // set position of the player based on the joystick input
    // position += game.joystick.relativeDelta.normalized() * 200 * dt;

    // combine joystick and keyboard input
    final Vector2 movement = game.joystick.relativeDelta + _keyboardMovement;
    position += movement.normalized() * 200 * dt;

    _handleScreenBounds();

    // perform shooting if the player is shooting
    // add delay for the shooting
    _elapsedFireTime += dt;
    if (_isShooting && _elapsedFireTime >= _fireCooldown ) {
      _fireLaser();
      _elapsedFireTime = 0.0;
    
    }

    super.update(dt);
  }

  Future<SpriteAnimation> _loadAnimation() async {
    return SpriteAnimation.spriteList(
      [
        await game.loadSprite('player_blue_on0.png'),
        await game.loadSprite('player_blue_on1.png'),
      ],
      stepTime: 0.1,
      loop: true
    );
  }

  // set screen boundaries for the player
  void _handleScreenBounds() {
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    // top and bottom boundaries
    // prevent the player from going out of the screen
    position.y = clampDouble(position.y, size.y / 2 , screenHeight - size.y / 2);


    // left and right boundaries
    if (position.x < 0) {
      position.x = screenWidth;
    } else if(position.x > screenWidth) {
      position.x = 0;
    }
  }

  // a method to shoot laser
  void startShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  } 

  void _fireLaser() {
    game.add(
      Laser(
        position: position.clone() + Vector2(0, -size.y / 2),
      )
    );

    if (_laserPowerupTimer.isRunning()) {
      game.add(
        Laser(
          position: position.clone() + Vector2(0, -size.y / 2),
          angle: 15 * degrees2Radians,
        )
      );
      game.add(
        Laser(
          position: position.clone() + Vector2(0, -size.y / 2),
          angle: -15 * degrees2Radians,
        )
      );
    }
  }

  // player destruction
  void _handleDestruction() async {
    animation = SpriteAnimation.spriteList(
      [
        await game.loadSprite('player_blue_off.png'),
      ], 
      stepTime: double.infinity
    );

    add(ColorEffect(
      const Color.fromRGBO(255, 255, 255, 1.0), 
      EffectController(duration: 0.0),
      )
    );

    add(OpacityEffect.fadeOut(
      EffectController(duration: 3.0),
      onComplete: () => _explosionTimer.stop()
    ));

    add(MoveEffect.by(
      Vector2(0, 200), 
      EffectController(duration: 3.0)
    ));

    add(RemoveEffect(delay: 4.0));

    _isDestroyed = true;

    _explosionTimer.start();
  }

  void _createRandomExplosion() {
    final Vector2 explosionPosition = Vector2(
      position.x - size.x / 2 + _random.nextDouble() * size.x,
      position.y - size.y / 2 + _random.nextDouble() * size.y
    );

    final ExplosionType explosionType = _random.nextBool()
        ? ExplosionType.smoke
        : ExplosionType.fire;

    final Explosion explosion = Explosion(
      position: explosionPosition, 
      explosionSize: size.x * 0.7, 
      explosionType: explosionType
    );

    game.add(explosion);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);

    if (_isDestroyed) return;

    if(other is Asteriod) {
      if (activeShield == null)  _handleDestruction();
    } else if (other is Pickup) {
      other.removeFromParent();
      game.incrementScore(1);

      // check which type of pickup is
      switch (other.pickupType) {
        case PickupType.laser:
          _laserPowerupTimer.start();
          break;
        case PickupType.bomb:
          game.add(Bomb(position: position.clone()));
          break;
        case PickupType.shield:
          if(activeShield != null) {
            remove(activeShield!);
          }

          activeShield = Shield();
          add(activeShield!);
          break;
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // TODO: implement onKeyEvent
    _keyboardMovement.x = 0;
    _keyboardMovement.x += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _keyboardMovement.x += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;


    _keyboardMovement.y = 0;
    _keyboardMovement.y += keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0;
    _keyboardMovement.y += keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0;

    return true;
  }
}