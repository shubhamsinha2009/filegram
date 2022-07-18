import 'core/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/firebase_analytics.dart';
import 'routes/app_pages.dart';

class PdfWallah extends StatelessWidget {
  const PdfWallah({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PdfWallah',
      initialRoute: AppPages.intial,
      getPages: AppPages.routes,
      themeMode: ThemeMode.system,
      darkTheme: Themes.appDarkTheme,
      theme: Themes.appLightTheme,
      enableLog: true,
      navigatorObservers: [
        AnalyticsService.observer,
      ],
    );
  }
}
