import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PuzzleSolved extends StatelessWidget {
  final String name;

  const PuzzleSolved({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Puzzle solved! You found",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Center(child: Lottie.asset('assets/confetti.json')),
      ],
    );
  }
}
