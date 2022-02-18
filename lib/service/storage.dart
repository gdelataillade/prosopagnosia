import 'package:hive/hive.dart';

class Storage {
  static Future init() async {
    await Hive.openBox('app');
  }

  static Box<dynamic> getBox() => Hive.box('app');
  static int getNbAvatars() => getBox().values.length;

  static List<String> getStoredAvatar() {
    final box = getBox();

    print("Storage: ${box.values.toList()}");
    return box.values.map((e) => e.toString()).toList();
  }

  static void storeNewAvatar(String name) {
    final box = getBox();

    box.put(getNbAvatars(), name);
    print("Storage: ${box.values.toList()}");
  }
}
