import 'package:hive_flutter/hive_flutter.dart';
import 'core/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/firebase_analytics.dart';
import 'routes/app_pages.dart';

class Filegram extends StatelessWidget {
  const Filegram({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Hive.box('settings').get('darkmode', defaultValue: true);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Filegram',
      initialRoute: AppPages.intial,
      getPages: AppPages.routes,
      theme: Themes.appLightTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: Themes.appDarkTheme,
      enableLog: true,
      navigatorObservers: [
        AnalyticsService.observer,
      ],
    );
  }
}
