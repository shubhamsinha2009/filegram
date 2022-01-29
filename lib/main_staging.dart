import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/core/services/init_services.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initServices();
  runApp(
    const Filegram(),
  );
}
