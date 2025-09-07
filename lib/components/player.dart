import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:space_battle/components/laser.dart';
import 'package:space_battle/my_game.dart';

class Player extends SpriteComponent with HasGameReference<MyGame>{
  bool _isShooting = false;

  @override
  FutureOr<void> onLoad() async{
    // TODO: implement onLoad
    sprite = await game.loadSprite('player_blue_on0.png');

    // resize the player
    size *= 0.3;

    return super.onLoad();
  }

  // update the position of the player
  @override
  void update(double dt) {
    // TODO: implement update
    // handle the movement of the player
    // base on the computer/device complexity using dt
    // position.y -= 200 * dt;

    // getting the joystick input
    // print(game.joystick.relativeDelta);

    // set position of the player based on the joystick input
    position += game.joystick.relativeDelta.normalized() * 200 * dt;

    _handleScreenBounds();

    // perform shooting if the player is shooting
    if (_isShooting) {
      _fireLaser();
    
    }

    super.update(dt);
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
  }
}