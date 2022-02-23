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
                        painter: AvatarPainter(
                            state.svgRoots[i], const Size(80, 80)),
                      ),
                    ),
                    Text(state.names[i]),
                  ],
                ),
            ],
          ));
  }
}
