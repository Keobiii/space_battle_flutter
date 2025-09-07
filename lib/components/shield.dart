import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:space_battle/components/asteriod.dart';
import 'package:space_battle/my_game.dart';

class Shield extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  Shield(): super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() async{
    // TODO: implement onLoad
    sprite = await game.loadSprite('shield.png');

    position += game.player.size / 2;

    add(CircleHitbox());

    final ScaleEffect pulsatingEffect = ScaleEffect.to(
      Vector2.all(1.1),
      EffectController(
        duration: 0.6,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut
      ) 
    );

    add(pulsatingEffect);

    final OpacityEffect fadeOutEffect = OpacityEffect.fadeOut(
      EffectController(
        duration: 3.0,
      ),
      onComplete: () {
        removeFromParent();
        game.player.activeShield = null;
      },
    );
    add(fadeOutEffect);
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);

    if(other is Asteriod) {
      other.takeDamage();
    }
  }
}