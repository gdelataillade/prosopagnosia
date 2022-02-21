import 'package:flutter/material.dart';

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
