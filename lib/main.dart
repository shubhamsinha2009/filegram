import 'package:filegram/app/core/themes/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/services/firebase_analytics.dart';
import 'app/core/services/init_services.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initServices();
  runApp(
    const Filegram(),
  );
}

class Filegram extends StatelessWidget {
  const Filegram({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Filegram",
      initialRoute: AppPages.intial,
      getPages: AppPages.routes,
      theme: Themes.appDarkTheme,
      enableLog: true,
      navigatorObservers: [
        AnalyticsService.observer,
      ],
    );
  }
}
