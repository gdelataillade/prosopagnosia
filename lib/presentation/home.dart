import 'dart:math';

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

  Future<void> generateAvatars(List<String> names) async {
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
    final names = Storage.getStoredAvatar();
    generateAvatars(names);
  }

  @override
  Widget build(BuildContext context) {
    return svgRoots.isEmpty
        ? const Text('You don\'t have any trophies yet...')
        : Row(
            children: [
              for (var i = 0; i < svgRoots.length; i++)
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
  List<Map<String, dynamic>> puzzle = [];
  int? blankIndex;
  bool isSolved = false;

  Future<void> generateNewPuzzle() async {
    final randomAvatar = await DrawableTools.generateRandomAvatar();
    final splittedAvatar = await DrawableTools.splitAvatar(randomAvatar);

    puzzle.clear();
    blankIndex = 8;

    setState(() {
      for (int i = 0; i < 9; i++) {
        puzzle.add(
          {
            "index": i,
            "image": splittedAvatar[i],
          },
        );
      }

      puzzle.shuffle();

      if (puzzle[blankIndex!]["index"] != 8) {
        final lastTile =
            puzzle.where((tile) => tile["index"] == blankIndex).first;
        final lastTileIndex = puzzle.indexOf(lastTile);
        final otherTile = puzzle[blankIndex!];

        puzzle[blankIndex!] = lastTile;
        puzzle[lastTileIndex] = otherTile;
      }
    });
  }

  // List<Map<String, dynamic>> shufflePuzzle(List<Map<String, dynamic>> list) {

  // }

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

  void onTap(int index) {
    if (isNextToBlank(index)) {
      final tmp = puzzle[blankIndex!];

      setState(() {
        puzzle[blankIndex!] = puzzle[index];
        puzzle[index] = tmp;
        blankIndex = index;

        for (int i = 0; i < 9; i++) {
          if (puzzle[i]["index"] != i) return;
        }
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
                : GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    children: [
                      for (var i = 0; i < 9; i++)
                        blankIndex == i
                            ? const SizedBox.expand()
                            : PuzzleTile(
                                image: Image(image: puzzle[i]["image"].image),
                                onPressed: () => onTap(i),
                              ),
                    ],
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
