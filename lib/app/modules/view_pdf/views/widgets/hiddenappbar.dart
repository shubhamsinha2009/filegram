import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/view_pdf_controller.dart';

class HiddenAppBar extends StatelessWidget {
  const HiddenAppBar({
    super.key,
    required this.controller,
  });

  final ViewPdfController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Obx(
          () => controller.hideAppBar.isFalse
              ? Container(
                  alignment: Alignment.topCenter,
                  height: 50,
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          color: Colors.grey,
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back)),
                      Obx(() => controller.isInterstitialAdLoaded.isTrue
                          ? Chip(
                              backgroundColor: Colors.grey,
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              shape: const StadiumBorder(),
                              label: Text(
                                'Ad in ${controller.countdownTimer.value} sec',
                                softWrap: true,
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            )),
                      IconButton(
                          color: Colors.grey,
                          onPressed: () async => await Share.shareXFiles(
                                [XFile(controller.filePath)],
                                text:
                                    'Download Filegram to open this file 🔓- https://play.google.com/store/apps/details?id=com.sks.filegram',
                              ),
                          icon: const Icon(Icons.share)),
                      Obx(() => IconButton(
                          color: Colors.grey,
                          onPressed: () {
                            controller.changeTheme.toggle();
                            controller.hideAppBar.toggle();
                          },
                          icon: Icon(
                            controller.changeTheme.isTrue
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ))),
                      // IconButton(
                      //     onPressed: () => null,
                      //     icon: const Icon(Icons.collections_bookmark))
                      // IconButton(
                      //     color: Colors.grey,
                      //     onPressed: () {
                      //       controller.swipehorizontal.toggle();
                      //       // controller.hideAppBar.toggle();
                      //     },
                      //     icon:
                      //         const Icon(Icons.rotate_90_degrees_ccw_outlined)),
                    ],
                  ),
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
        ));
  }
}
