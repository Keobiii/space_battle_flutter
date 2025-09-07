import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_battle/my_game.dart';
import 'package:space_battle/overlays/game_over_overlay.dart';

void main() {
  final MyGame game = MyGame(); 
  
  runApp(GameWidget(
    game: game,
    overlayBuilderMap: {
      'GameOver': (context, MyGame game) => GameOverOverlay(game: game)
    },
  ));
}



