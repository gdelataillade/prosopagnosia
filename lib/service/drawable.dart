import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:image/image.dart' as imglib;

const boardSize = 600.0;

class DrawableTools {
  static Future<DrawableRoot> generateAvatar(String name) async {
    String svgCode = multiavatar(name);
    DrawableRoot avatar = await svg.fromSvgString(svgCode, name);

    return avatar;
  }

  static Future<DrawableRoot> generateRandomAvatar(String name) async {
    String svgCode = multiavatar(name, trBackground: true);
    DrawableRoot avatar = await svg.fromSvgString(svgCode, name);

    return avatar;
  }

  static Future<List<Image>> splitAvatar(DrawableRoot svgRoot) async {
    const colorFilter = ColorFilter.mode(Color(0xFFDDDDDD), BlendMode.overlay);
    final image = await svgRoot
        .toPicture(
            size: const Size(boardSize, boardSize), colorFilter: colorFilter)
        .toImage(boardSize.toInt(), boardSize.toInt());

    try {
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) throw ('byteData');

      final currentImage = imglib.decodeImage(byteData.buffer.asUint8List());
      if (currentImage == null) throw ('currentImage');
      return splitImage(currentImage);
    } catch (e) {
      print("DrawableTools: splitAvatar error: $e");
      return [];
    }
  }

  static List<Image> splitImage(imglib.Image image) {
    int x = 0, y = 0;
    int width = (image.width / 3).round();
    int height = (image.height / 3).round();

    List<imglib.Image> parts = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }

    List<Image> output = [];
    for (imglib.Image img in parts) {
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }

    return output;
  }
}
