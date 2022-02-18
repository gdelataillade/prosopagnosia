import 'package:flutter/material.dart';

class PuzzleTile extends StatelessWidget {
  final Image image;
  final Function() onPressed;

  const PuzzleTile({
    Key? key,
    required this.image,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(5),
        elevation: 2,
        primary: const Color(0xFF925001),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image,
      ),
    );
  }
}
