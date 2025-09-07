import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:space_battle/components/asteriod.dart';
import 'package:space_battle/components/pickup.dart';
import 'package:space_battle/components/player.dart';
import 'package:space_battle/components/shoot_button.dart';
import 'package:flutter/material.dart';
import 'package:space_battle/components/stars.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection{
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _asteroidSpawner;
  late SpawnComponent _pickupSpawner;
  final Random _random = Random();
  late ShootButton _shootButton;
  int _score = 0;
  late TextComponent _scoreDisplay;

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    _createStars();

    // debugMode = true;

    // startGame();

    return super.onLoad();
  }

  // @override
  // Color backgroundColor() {
  //   return const Color.fromRGBO(255, 0, 0, 1.0);
  // }

  void startGame() async {
    await _createJoystick();
    await _createPlayer();
    _createShootButton();
    _createAsteroidSpawner();
    _createPickupSpawner();
    _createScoreDisplay();

    // manually create an asteriod
    // add(Asteriod(position: Vector2(200, 0)));
  }

  Future<void> _createPlayer() async{
    player = Player()
      // set the placement of the player
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y * 0.8);

    add(player);
  }

  Future<void> _createJoystick() async{
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: await loadSprite('joystick_knob.png'),
        size: Vector2.all(50),
      ),
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(100),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(50, size.y - 20),
      priority: 0,
    );
    add(joystick);
  }

  void _createShootButton() {
    _shootButton = ShootButton()
    ..anchor = Anchor.bottomRight
    ..position = Vector2(size.x - 20, size.y - 20)
    ..priority = 10;

    add(_shootButton);
  }

  void _createAsteroidSpawner() {
    _asteroidSpawner = SpawnComponent.periodRange(
      factory: (index) => Asteriod(position: _generateSpawnPosition()),
      minPeriod: 0.7,
      maxPeriod: 1.2,
      selfPositioning: true,
    );
    add(_asteroidSpawner);
  }

  void _createPickupSpawner() {
    _pickupSpawner = SpawnComponent.periodRange(
      factory: (index) => Pickup(
        position: _generateSpawnPosition(),
        pickupType: PickupType.values[_random.nextInt(PickupType.values.length)]
      ),
      minPeriod: 5.0,
      maxPeriod: 10.0,
      selfPositioning: true,
    );
    add(_pickupSpawner);
  }

  Vector2 _generateSpawnPosition() {
    return Vector2(10 + _random.nextDouble() * (size.x - 19 * 2), -100);
  }

  // score display
  void _createScoreDisplay() {
    _score = 0;

    _scoreDisplay = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 20),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 2
            ),
          ]
        )
      ),
    );

    add(_scoreDisplay);
  }

  void incrementScore(int amount) {
    _score += amount;
    _scoreDisplay.text = _score.toString();

    final ScaleEffect popEffect = ScaleEffect.to(
      Vector2.all(1.2),
      EffectController(
        duration: 0.05,
        alternate: true,
        curve: Curves.easeInOut,
      )
    );

    _scoreDisplay.add(popEffect);
  }

  void _createStars() {
    for(int i = 0; i < 50; i++) {
      add(Stars()..priority = -10);
    }
  }

  void gameOver() {
    overlays.add('GameOver');
    pauseEngine();
  }

  void restartGame() {
    // remove asteroids and pickups
    children.whereType<PositionComponent>().forEach((component) {
      if (component is Asteriod || component is Pickup) {
        remove(component);
      }
    });

    _asteroidSpawner.timer.start();
    _pickupSpawner.timer.start();

    // reset the score
    _score = 0;
    _scoreDisplay.text = '0';


    // create new player
    _createPlayer();

    resumeEngine();
  }

  void quitGame() {
    // go back with the title and remove everything
    children.whereType<PositionComponent>().forEach((component) {
      if (component is! Stars) {
        remove(component);
      }
    });

    remove(_asteroidSpawner);
    remove(_pickupSpawner);

    // show title overlay
    overlays.add('Title');

    resumeEngine();
  }
}