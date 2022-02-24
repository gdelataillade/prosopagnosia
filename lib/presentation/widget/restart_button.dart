import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prosopagnosia/presentation/state.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class RestartButton extends StatelessWidget {
  const RestartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Get.find<GameState>();
    final RoundedLoadingButtonController controller =
        RoundedLoadingButtonController();
    return RoundedLoadingButton(
      onPressed: () async {
        controller.start();
        await state.generateNewPuzzle();
        controller.success();
        await Future.delayed(const Duration(seconds: 1));
        controller.reset();
      },
      controller: controller,
      child: const Text(
        "New avatar",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
