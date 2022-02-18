import 'package:flutter/material.dart';
import 'package:prosopagnosia/presentation/home.dart';
import 'package:prosopagnosia/service/storage.dart';

Future<void> main() async {
  await Storage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Hackaton 2022: prosopagnosia',
      home: Home(),
    );
  }
}
