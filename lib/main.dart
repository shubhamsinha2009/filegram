import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() {
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
      title: "Filegram",
      initialRoute: AppPages.intial,
      getPages: AppPages.routes,
    );
  }
}
