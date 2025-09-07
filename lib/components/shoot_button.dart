import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:space_battle/my_game.dart';

class ShootButton extends SpriteComponent with HasGameReference<MyGame>, TapCallbacks {
  ShootButton() : super(
    size: Vector2.all(80),
  );

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    sprite = await game.loadSprite('shoot_button.png');

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // TODO: implement onTapDown
    game.player.startShooting();

    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // TODO: implement onTapUp
    game.player.stopShooting();

    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // TODO: implement onTapCancel
    game.player.stopShooting();

    super.onTapCancel(event);
  }
}