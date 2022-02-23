import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/presentation/game.dart';
import 'package:prosopagnosia/presentation/state.dart';
import 'package:prosopagnosia/presentation/trophies.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: GetX<GameState>(
        init: GameState(),
        builder: (state) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Trophies(),
            state.puzzle.isEmpty
                ? const CircularProgressIndicator()
                : const Game(),
          ],
        ),
      ),
    );
  }
}
