import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/presentation/state.dart';
import 'package:prosopagnosia/presentation/widget/avatar_painter.dart';

class Trophies extends StatelessWidget {
  const Trophies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Get.find<GameState>();
    return Obx(() => state.svgRoots.isEmpty
        ? const Text('You don\'t have any trophies yet...')
        : Row(
            children: [
              for (var i = 0; i < state.svgRoots.length; i++)
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CustomPaint(
                          painter: AvatarPainter(
                              state.svgRoots[i], const Size(80, 80)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(state.names[i]),
                    ],
                  ),
                ),
            ],
          ));
  }
}
