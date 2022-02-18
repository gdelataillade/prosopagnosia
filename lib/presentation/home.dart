import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prosopagnosia/presentation/avatar_painter.dart';
import 'package:prosopagnosia/presentation/widget/puzzle_tile.dart';
import 'package:prosopagnosia/service/drawable.dart';
import 'package:prosopagnosia/service/storage.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Trophies(),
          Game(),
        ],
      ),
    );
  }
}

class Trophies extends StatefulWidget {
  const Trophies({Key? key}) : super(key: key);

  @override
  State<Trophies> createState() => _TrophiesState();
}

class _TrophiesState extends State<Trophies> {
  List<DrawableRoot> svgRoots = [];
  List<String> names = [];

  Future<void> generateAvatars() async {
    List<DrawableRoot> tmp = [];

    for (var i = 0; i < names.length; i++) {
      final avatar = await DrawableTools.generateAvatar(names[i]);
      tmp.add(avatar);
    }
    setState(() => svgRoots = tmp);
  }

  @override
  void initState() {
    super.initState();
    // Storage.storeNewAvatar("3");
    names = Storage.getStoredAvatar();
    generateAvatars();
  }

  @override
  Widget build(BuildContext context) {
    return svgRoots.isEmpty
        ? const Text('You don\'t have any trophies yet...')
        : Row(
            children: [
              for (var i = 0; i < svgRoots.length; i++)
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
                        painter: AvatarPainter(svgRoots[i], const Size(80, 80)),
                      ),
                    ),
                    Text(names[i]),
                  ],
                ),
            ],
          );
  }
}

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final random = Random();
  late String avatarName;
  List<Map<String, dynamic>> puzzle = [];
  late int blankIndex;
  bool isSolved = false;

  int? shiftingIndex;
  double xShift = 0;
  double yShift = 0;

  Future<void> generateNewPuzzle() async {
    avatarName = Faker().person.firstName();

    final randomAvatar = await DrawableTools.generateRandomAvatar(avatarName);
    final splittedAvatar = await DrawableTools.splitAvatar(randomAvatar);

    puzzle.clear();
    blankIndex = 8;

    setState(() {
      isSolved = false;

      for (int i = 0; i < 9; i++) {
        puzzle.add(
          {
            "index": i,
            "image": splittedAvatar[i],
          },
        );
      }

      shufflePuzzle();

      if (puzzle[blankIndex]["index"] != 8) {
        final lastTile =
            puzzle.where((tile) => tile["index"] == blankIndex).first;
        final lastTileIndex = puzzle.indexOf(lastTile);
        final otherTile = puzzle[blankIndex];

        puzzle[blankIndex] = lastTile;
        puzzle[lastTileIndex] = otherTile;
      }
    });
  }

  void swapTiles(int tileIndex, int blankIdx) {
    final tmp = puzzle[tileIndex];

    puzzle[tileIndex] = puzzle[blankIdx];
    puzzle[blankIdx] = tmp;
    blankIndex = tileIndex;
  }

  void shufflePuzzle() {
    for (int i = 0; i < 30; i++) {
      int index = random.nextInt(8);

      while (!isNextToBlank(index)) {
        index = random.nextInt(8);
      }
      swapTiles(index, blankIndex);
    }
  }

  bool isNextToBlank(int index) {
    if (index + 1 == blankIndex && blankIndex != 3 && blankIndex != 6) {
      return true;
    }
    if (index - 1 == blankIndex && blankIndex != 2 && blankIndex != 5) {
      return true;
    }
    if (index - 3 == blankIndex || index + 3 == blankIndex) {
      return true;
    }
    return false;
  }

  void checkWin() {
    for (int i = 0; i < 9; i++) {
      if (puzzle[i]["index"] != i) return;
    }
    isSolved = true;
    Storage.storeNewAvatar(avatarName);
    print("PUZZLE SOLVED!");
  }

  void onTap(int index) {
    if (isNextToBlank(index)) {
      setState(() {
        if (index + 1 == blankIndex) xShift = 198;
        if (index - 1 == blankIndex) xShift = -198;
        if (index + 3 == blankIndex) yShift = 198;
        if (index - 3 == blankIndex) yShift = -198;

        shiftingIndex = index;
      });
    }
  }

  @override
  void initState() {
    generateNewPuzzle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            height: tileSize,
            width: tileSize,
            child: puzzle.isEmpty
                ? const SizedBox.shrink()
                : isSolved
                    ? PuzzleSolved(name: avatarName)
                    : SizedBox(
                        height: 600,
                        width: 600,
                        child: Stack(
                          children: [
                            for (int i = 0; i < 9; i++)
                              AnimatedPositioned(
                                top: 200 * (i ~/ 3).toDouble() +
                                    (shiftingIndex != null && shiftingIndex == i
                                        ? yShift
                                        : 0),
                                left: 200 * (i % 3).toDouble() +
                                    (shiftingIndex != null && shiftingIndex == i
                                        ? xShift
                                        : 0),
                                onEnd: () => setState(() {
                                  shiftingIndex = null;
                                  xShift = 0;
                                  yShift = 0;
                                  swapTiles(i, blankIndex);
                                  checkWin();
                                }),
                                curve: Curves.fastOutSlowIn,
                                duration: const Duration(milliseconds: 150),
                                child: blankIndex == i
                                    ? const SizedBox()
                                    : PuzzleTile(
                                        image: Image(
                                            image: puzzle[i]["image"].image),
                                        onPressed: () => onTap(i),
                                      ),
                              ),
                          ],
                        ),
                      ),
          ),
        ),
        const SizedBox(height: 60),
        RawMaterialButton(
          fillColor: Colors.indigo,
          onPressed: generateNewPuzzle,
          child: const Text(
            "New avatar",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class PuzzleSolved extends StatelessWidget {
  final String name;

  const PuzzleSolved({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Puzzle solved! You unlocked $name"),
    );
  }
}
