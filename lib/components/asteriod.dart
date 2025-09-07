import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_battle/my_game.dart';

class Asteriod extends SpriteComponent with HasGameReference<MyGame> { 
  final Random _random = Random();
  static const double _maxSize = 120;
  late Vector2 _velocity;
  final Vector2 _originalVelocity = Vector2.zero();
  late double _spinSpeed;
  final double _maxHalth = 3;
  late double _health;
  bool _isKnockedback = false;

  Asteriod({ 
    required super.position,
    double size = _maxSize
  }) : super(
    size: Vector2.all(size), 
    anchor: Anchor.center,
    priority: -1
  ) {
    _velocity = _generateVelocity();
    _originalVelocity.setFrom(_velocity);
    _spinSpeed = (_random.nextDouble() * 1.5 - 0.75); 
    _health = size / _maxSize * _maxHalth;

    add(CircleHitbox());
  }

  @override
  FutureOr<void> onLoad() async{
    // TODO: implement onLoad
    final int imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('asteroid$imageNum.png');

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    // position.y += 150 * dt;
    position += _velocity * dt;

    _handleScreenBounds();

    angle += _spinSpeed * dt;
    
    super.update(dt);
  }

  Vector2 _generateVelocity() {
    final double forceFactor = _maxSize / size.x;
    return Vector2(_random.nextDouble() * 120 - 60, 
    100 + _random.nextDouble() * 50
    ) * forceFactor;
  }

  void _handleScreenBounds() {
    // remove asteriod when it goes out of the screen
    if (position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }

    // wrap around the asteriod when it goes out of the screen
    final double screenWidth = game.size.x;
    if (position.x < -size.x / 2) {
      position.x = screenWidth + size.x / 2;
    } else if (position.x > screenWidth + size.x / 2) {
      position.x = -size.x / 2;
    }
  }

  // dealing damage to the asteriod
  void takeDamage() {
    _health--;

    if (_health <= 0) {
      removeFromParent();
    } else {
      _flashWhite();
      _applyKnockback();
    }
  }

  // effects when the asteriod is hitted
  void _flashWhite() {
    final ColorEffect flashEffect = ColorEffect(
      const Color.fromRGBO(255, 255, 255, 1.0),
      EffectController(
        duration: 0.1,
        alternate: true,
        curve: Curves.easeInOut
      ),
    );

    add(flashEffect);
  }

  // effects when the asteriod is destroyed
  void _applyKnockback() {
    if(_isKnockedback) return;

    _isKnockedback = true;
    _velocity.setZero();

    final MoveByEffect knockbackEffect = MoveByEffect(
      Vector2(0, -20), 
      EffectController(
        duration: 0.1,
      ),
      onComplete: _restoreVelocity
    );

    add(knockbackEffect);
  }

  void _restoreVelocity() {
    _velocity.setFrom(_originalVelocity);

    _isKnockedback = false;
  }
}