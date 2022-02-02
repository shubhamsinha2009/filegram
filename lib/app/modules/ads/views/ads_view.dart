import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ads_controller.dart';

class AdsView extends GetView<AdsController> {
  const AdsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(15),
        width: controller.inlineBannerAd.size.width.toDouble() + 15,
        height: controller.inlineBannerAd.size.height.toDouble() + 15,
        child: controller.adWidget(ad: controller.inlineBannerAd),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black54,
                Colors.black87,
              ],
            ),
            //color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade900,
                offset: const Offset(5, 5),
                blurRadius: 5,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.grey.shade800,
                offset: const Offset(-4, -4),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ]));
  }
}
