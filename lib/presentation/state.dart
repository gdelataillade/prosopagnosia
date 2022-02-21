import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/service/drawable.dart';
import 'package:prosopagnosia/service/storage.dart';

enum GameStep {
  loading,
  game,
  solved,
}

class GameState extends GetxController {
  final random = Random();
  final faker = Faker();

  Rx<GameStep> step = GameStep.loading.obs;

  // Trophies
  RxList<DrawableRoot> svgRoots = <DrawableRoot>[].obs;
  RxList<String> names = <String>[].obs;

  // Game
  RxList<Map<String, dynamic>> puzzle = <Map<String, dynamic>>[].obs;
  late String avatarName;
  late RxInt blankIndex;

  int get blankIdx => blankIndex.value;

  @override
  void onInit() {
    names.assignAll(Storage.getStoredAvatar());
    generateAvatars();
    generateNewPuzzle();
    super.onInit();
  }

  // Trophies
  Future<void> generateAvatars() async {
    List<DrawableRoot> tmp = [];

    for (var i = 0; i < names.length; i++) {
      final avatar = await DrawableTools.generateAvatar(names[i]);
      tmp.add(avatar);
    }
    svgRoots.assignAll(tmp);
  }

  // Game
  Future<void> generateNewPuzzle() async {
    avatarName = faker.person.firstName();

    final randomAvatar = await DrawableTools.generateRandomAvatar(avatarName);
    final splittedAvatar = await DrawableTools.splitAvatar(randomAvatar);

    puzzle.clear();
    blankIndex = 8.obs;

    step = GameStep.game.obs;

    for (int i = 0; i < 9; i++) {
      puzzle.add(
        {"index": i, "image": splittedAvatar[i]},
      );
    }

    shufflePuzzle();

    if (puzzle[blankIdx]["index"] != 8) {
      final lastTile = puzzle.where((tile) => tile["index"] == blankIdx).first;
      final lastTileIndex = puzzle.indexOf(lastTile);
      final otherTile = puzzle[blankIdx];

      puzzle[blankIdx] = lastTile;
      puzzle[lastTileIndex] = otherTile;
    }

    step = GameStep.game.obs;
  }

  void shufflePuzzle() {
    for (int i = 0; i < 30; i++) {
      int index = random.nextInt(8);

      while (!isNextToBlank(index)) {
        index = random.nextInt(8);
      }
      swapTiles(index, blankIdx);
    }
  }

  bool isNextToBlank(int index) {
    if (index + 1 == blankIdx && blankIdx != 3 && blankIdx != 6) {
      return true;
    }
    if (index - 1 == blankIdx && blankIdx != 2 && blankIdx != 5) {
      return true;
    }
    if (index - 3 == blankIdx || index + 3 == blankIdx) {
      return true;
    }
    return false;
  }

  void swapTiles(int tileIndex, int blankIdx) {
    final tmp = puzzle[tileIndex];

    puzzle[tileIndex] = puzzle[blankIdx];
    puzzle[blankIdx] = tmp;
    blankIndex = tileIndex.obs;
  }

  void checkWin() {
    for (int i = 0; i < 9; i++) {
      if (puzzle[i]["index"] != i) return;
    }
    step = GameStep.solved.obs;
    Storage.storeNewAvatar(avatarName);
    names.assignAll([...names, avatarName]);
    generateAvatars();
    print("PUZZLE SOLVED!");
  }
}
