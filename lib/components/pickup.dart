import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_battle/my_game.dart';

enum PickupType {
  bomb,
  laser,
  shield
}

class Pickup extends SpriteComponent with HasGameReference<MyGame> {
  final PickupType pickupType;

  Pickup({
    required super.position,
    required this.pickupType,
  }) : super(
    size: Vector2.all(100),
    anchor: Anchor.center
  );

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    sprite = await game.loadSprite('${pickupType.name}_pickup.png');

    add(CircleHitbox());

    final ScaleEffect pulsatingEffect = ScaleEffect.to(
      Vector2.all(0.9), 
      EffectController(
        duration: 0.6,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut
      ),
    );

    add(pulsatingEffect);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    position.y += 300 * dt;

    // remove pickup item from gameif it goes below the bottom
    if (position.y > game.size.y + size.y / 2) {
       removeFromParent();
    }
  }
}