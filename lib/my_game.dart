import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:space_battle/components/asteriod.dart';
import 'package:space_battle/components/player.dart';

class MyGame extends FlameGame {
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _asteroidSpawner;
  final Random _random = Random();

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    startGame();

    return super.onLoad();
  }

  // @override
  // Color backgroundColor() {
  //   return const Color.fromRGBO(255, 0, 0, 1.0);
  // }

  void startGame() async {
    await _createJoystick();
    _createPlayer();
    _createAsteroidSpawner();

    // manually create an asteriod
    // add(Asteriod(position: Vector2(200, 0)));
  }

  void _createPlayer() {
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

  void _createAsteroidSpawner() {
    _asteroidSpawner = SpawnComponent.periodRange(
      factory: (index) => Asteriod(position: _generateSpawnPosition()),
      minPeriod: 0.7,
      maxPeriod: 1.2,
      selfPositioning: true,
    );
    add(_asteroidSpawner);
  }

  Vector2 _generateSpawnPosition() {
    return Vector2(10 + _random.nextDouble() * (size.x - 19 * 2), -100);
  }
}