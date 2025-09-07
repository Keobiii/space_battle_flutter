import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_battle/components/asteriod.dart';
import 'package:space_battle/my_game.dart';

class Laser extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
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

    size *= 0.25;

    add(RectangleHitbox(

    ));

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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);

    if(other is Asteriod) {
      removeFromParent();
      other.takeDamage();
    }
  }
}