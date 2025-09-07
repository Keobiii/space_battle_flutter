import 'dart:async';

import 'package:flame/components.dart';
import 'package:space_battle/my_game.dart';

class ShootButton extends SpriteComponent with HasGameReference<MyGame> {
  ShootButton() : super(
    size: Vector2.all(80),
  );

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    sprite = await game.loadSprite('shoot_button.png');

    return super.onLoad();
  }
}