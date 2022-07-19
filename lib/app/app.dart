import 'core/services/getstorage.dart';
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
    bool? isDark = GetStorageDbService.getRead(key: 'darkmode');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PdfWallah',
      initialRoute: AppPages.intial,
      getPages: AppPages.routes,
      theme: Themes.appLightTheme,
      themeMode: isDark != null
          ? (isDark == true ? ThemeMode.dark : ThemeMode.light)
          : ThemeMode.system,
      darkTheme: Themes.appDarkTheme,
      enableLog: true,
      navigatorObservers: [
        AnalyticsService.observer,
      ],
    );
  }
}
