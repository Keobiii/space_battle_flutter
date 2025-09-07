import 'dart:async';

import 'package:flame/components.dart';
import 'package:space_battle/my_game.dart';

class Laser extends SpriteComponent with HasGameReference<MyGame> {
  Laser({
    required super.position,
  }) : super (
    anchor: Anchor.center,
    priority: - 1,
  );

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    sprite = await game.loadSprite('laser.png');

    size *= 0.5;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    position.y -= 500 * dt;

    // rmeove the laser when it goes out of the screen
    if (position.y < -size.y / 2) {
      removeFromParent();
    }

    super.update(dt);
  }
}