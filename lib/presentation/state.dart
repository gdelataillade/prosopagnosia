import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/service/drawable.dart';
import 'package:prosopagnosia/service/storage.dart';

class GameState extends GetxController {
  final random = Random();
  final faker = Faker();

  // Trophies
  RxList<DrawableRoot> svgRoots = <DrawableRoot>[].obs;
  RxList<String> names = <String>[].obs;

  // Game
  RxList<Map<String, dynamic>> puzzle = <Map<String, dynamic>>[].obs;
  RxBool isSolved = false.obs;
  late String avatarName;
  late RxInt blankIndex;
  RxInt shiftingIndex = (-1).obs;
  double xShift = 0;
  double yShift = 0;

  int get blankIdx => blankIndex.value;
  int get shiftingIdx => shiftingIndex.value;

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
    isSolved.value = false;
    avatarName = faker.person.firstName();

    final randomAvatar = await DrawableTools.generateRandomAvatar(avatarName);
    final splittedAvatar = await DrawableTools.splitAvatar(randomAvatar);

    puzzle.clear();
    blankIndex = 8.obs;

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
    blankIndex.value = tileIndex;
  }

  void checkWin() {
    for (int i = 0; i < 9; i++) {
      if (puzzle[i]["index"] != i) return;
    }
    isSolved.value = true;
    Storage.storeNewAvatar(avatarName);
    names.assignAll([...names, avatarName]);
    generateAvatars();
  }

  void onTap(int index) {
    const tileSize = boardSize / 3;

    if (isNextToBlank(index)) {
      if (index + 1 == blankIdx) xShift = tileSize;
      if (index - 1 == blankIdx) xShift = -tileSize;
      if (index + 3 == blankIdx) yShift = tileSize;
      if (index - 3 == blankIdx) yShift = -tileSize;

      shiftingIndex.value = index;
    }
  }

  void onEndAnimation(int index) {
    shiftingIndex.value = -1;
    xShift = 0;
    yShift = 0;
    swapTiles(index, blankIdx);
    checkWin();
  }
}
