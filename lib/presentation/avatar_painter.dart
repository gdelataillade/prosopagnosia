import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarPainter extends CustomPainter {
  AvatarPainter(this.svg, this.size);

  final DrawableRoot svg;
  final Size size;

  @override
  void paint(Canvas canvas, Size size) {
    svg.scaleCanvasToViewBox(canvas, size);
    svg.clipCanvasToViewBox(canvas);
    svg.draw(canvas, Rect.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
