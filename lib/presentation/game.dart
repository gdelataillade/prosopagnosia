import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/presentation/state.dart';
import 'package:prosopagnosia/presentation/widget/animated_puzzle_tile.dart';
import 'package:prosopagnosia/presentation/widget/solved.dart';
import 'package:prosopagnosia/service/drawable.dart';

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final state = Get.find<GameState>();

    return Obx(() => Column(
          children: [
            Center(
              child: SizedBox(
                height: boardSize,
                width: boardSize,
                child: state.puzzle.isEmpty
                    ? const SizedBox.shrink()
                    : state.step.value == GameStep.solved
                        ? PuzzleSolved(name: state.avatarName)
                        : SizedBox(
                            height: 600,
                            width: 600,
                            child: Stack(
                              children: [
                                for (int i = 0; i < 9; i++)
                                  AnimatedPuzzleTile(
                                    key: UniqueKey(),
                                    index: i,
                                  ),
                              ],
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 60),
            RawMaterialButton(
              fillColor: Colors.indigo,
              onPressed: state.generateNewPuzzle,
              child: const Text(
                "New avatar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ));
  }
}
