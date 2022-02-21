import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/presentation/avatar_painter.dart';
import 'package:prosopagnosia/presentation/state.dart';
import 'package:prosopagnosia/presentation/widget/puzzle_tile.dart';
import 'package:prosopagnosia/presentation/widget/solved.dart';
import 'package:prosopagnosia/service/drawable.dart';

// TODO: Mettre Getx state
// Animations victoire
// Timer ?
// UI / UX

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

class Trophies extends StatelessWidget {
  const Trophies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Get.find<GameState>();
    return Obx(() => state.svgRoots.isEmpty
        ? const Text('You don\'t have any trophies yet...')
        : Row(
            children: [
              for (var i = 0; i < state.svgRoots.length; i++)
                Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      margin: const EdgeInsets.only(left: 10.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CustomPaint(
                        painter: AvatarPainter(
                            state.svgRoots[i], const Size(80, 80)),
                      ),
                    ),
                    Text(state.names[i]),
                  ],
                ),
            ],
          ));
  }
}

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final state = Get.find<GameState>();

    return Obx(() => Column(
          children: [
            Center(
              child: SizedBox(
                height: tileSize,
                width: tileSize,
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

class AnimatedPuzzleTile extends StatefulWidget {
  final int index;

  const AnimatedPuzzleTile({Key? key, required this.index}) : super(key: key);

  @override
  State<AnimatedPuzzleTile> createState() => _AnimatedPuzzleTileState();
}

class _AnimatedPuzzleTileState extends State<AnimatedPuzzleTile> {
  final state = Get.find<GameState>();
  double xShift = 0;
  double yShift = 0;
  int shiftingIndex = -1;

  void onTap(int index) {
    if (state.isNextToBlank(index)) {
      setState(() {
        if (index + 1 == state.blankIdx) xShift = 198;
        if (index - 1 == state.blankIdx) xShift = -198;
        if (index + 3 == state.blankIdx) yShift = 198;
        if (index - 3 == state.blankIdx) yShift = -198;

        shiftingIndex = index;
      });
    }
  }

  void onEndAnimation(int index) {
    shiftingIndex = (-1);
    xShift = 0;
    yShift = 0;
    state.swapTiles(index, state.blankIdx);
    state.checkWin();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedPositioned(
        top: 200 * (widget.index ~/ 3).toDouble() +
            (shiftingIndex == widget.index ? yShift : 0),
        left: 200 * (widget.index % 3).toDouble() +
            (shiftingIndex == widget.index ? xShift : 0),
        onEnd: () => onEndAnimation(widget.index),
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 150),
        child: state.blankIdx == widget.index
            ? const SizedBox()
            : PuzzleTile(
                image: Image(image: state.puzzle[widget.index]["image"].image),
                onPressed: () => onTap(widget.index),
              ),
      ),
    );
  }
}
