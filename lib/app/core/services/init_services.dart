import 'package:hive_flutter/hive_flutter.dart';

Future<void> initServices() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('user');
  await Hive.openBox('pdf');
}
