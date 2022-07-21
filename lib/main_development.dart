import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'app/core/services/init_services.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env.development");

    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await initServices();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(const PdfWallah()));
  }, (error, stack) {
    debugPrint(error.toString());
    debugPrint(stack.toString());
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}
