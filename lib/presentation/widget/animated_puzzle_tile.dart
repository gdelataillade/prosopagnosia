import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/presentation/state.dart';
import 'package:prosopagnosia/presentation/widget/puzzle_tile.dart';
import 'package:prosopagnosia/service/drawable.dart';

class AnimatedPuzzleTile extends StatelessWidget {
  final int index;

  const AnimatedPuzzleTile({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Get.find<GameState>();
    const tileSize = boardSize / 3;

    return Obx(
      () => AnimatedPositioned(
        top: tileSize * (index ~/ 3).toDouble() +
            (state.shiftingIdx == index ? state.yShift : 0),
        left: tileSize * (index % 3).toDouble() +
            (state.shiftingIdx == index ? state.xShift : 0),
        onEnd: () => state.onEndAnimation(index),
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 150),
        child: state.blankIdx == index
            ? const SizedBox()
            : PuzzleTile(
                image: Image(image: state.puzzle[index]["image"].image),
                onPressed: () => state.onTap(index),
              ),
      ),
    );
  }
}
