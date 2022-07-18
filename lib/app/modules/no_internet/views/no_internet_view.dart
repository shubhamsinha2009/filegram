import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/no_internet_controller.dart';

class NoInternetView extends GetView<NoInternetController> {
  const NoInternetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.isOverlaysOpen) {
      Get.back(closeOverlays: true);
    }
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Switch On Internet Connection! ",
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 50,
            ),
            Lottie.asset('assets/no_internet.json'),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Pdf Wallah Needs Internet To Provide Its Services",
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
