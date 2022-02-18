import 'package:get/get.dart';

void setupController() =>
    Get.put<AvatarController>(AvatarController(), permanent: true);

class AvatarController extends GetxController {}
