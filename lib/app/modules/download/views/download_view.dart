import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../data/provider/firestore_data.dart';
import '../../../routes/app_pages.dart';
import '../controllers/download_controller.dart';

class DownloadView extends GetView<DownloadController> {
  const DownloadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Refresh Indicator in all pages
    return Scaffold(
        appBar: AppBar(
          title: const FittedBox(child: Text('Download')),
          actions: [
            Obx(() => IconButton(
                onPressed: () {
                  Get.changeThemeMode(
                      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  controller.homeController.changeTheme.toggle();
                },
                icon: Icon(
                  controller.homeController.changeTheme.isTrue
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ))),
            IconButton(
                onPressed: () {
                  Get.showSnackbar(GetSnackBar(
                    backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                    title: 'How to download file chapter  ?',
                    message:
                        'Just Press Button with download icon or try changing source link',
                    duration: const Duration(seconds: 5),
                  ));
                },
                icon: const Icon(Icons.info)),
            ActionChip(
              onPressed: () {
                Get.toNamed(Routes.gullak);
              },
              label: Row(
                children: [
                  Obx(() =>
                      Text('${controller.homeController.gullak.value.sikka}')),
                  const Icon(Icons.circle, color: Colors.amber),
                ],
              ),
              avatar: const Icon(Icons.savings_rounded,
                  color: Color.fromARGB(255, 194, 103, 70)),
              labelPadding: const EdgeInsets.only(
                left: 5,
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Obx(() => controller.bottomBannerAd != null &&
                    controller.isBottomBannerAdLoaded.isTrue
                ? SizedBox(
                    height: controller.bottomBannerAd?.size.height.toDouble(),
                    width: controller.bottomBannerAd?.size.width.toDouble(),
                    child: controller.adWidget(ad: controller.bottomBannerAd!),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  )),
            const Spacer(),
            Obx(() => Text(
                  '${(controller.received.value / controller.total.value * 100).toStringAsFixed(0)} %',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    // color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Obx(() => LinearProgressIndicator(
                    value: controller.received.value / controller.total.value,
                    backgroundColor: Colors.red[100],
                    valueColor: const AlwaysStoppedAnimation(Colors.red),
                    minHeight: 15,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              controller.chapter.name,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8),
            //   child: DropdownButtonFormField<String>(
            //     alignment: Alignment.center,
            //     isDense: true,

            //     value: controller.chapter.get,
            //     items: controller.chapter.links
            //         .map((e) => DropdownMenuItem<String>(
            //             value: e.link,
            //             child: Text('Source Link ${e.number}')))
            //         .toList(),
            //     onChanged: (link) async {
            //       if (link != null && link.isNotEmpty) {
            //         controller.currentLink = link;
            //         controller.isLoading.value = true;
            //         await controller.getdetails(link);
            //       }
            //     },
            //     // borderRadius: const BorderRadius.all(Radius.circular(10)),
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            Obx(() => controller.isLoading.isFalse
                ? controller.getDetails.isFalse
                    ? File(controller.bookPath).existsSync()
                        ? OutlinedButton.icon(
                            onPressed: () {
                              Get.toNamed(Routes.viewPdf,
                                  arguments: [controller.bookPath, true]);
                            },
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Open File'),
                          )
                        : OutlinedButton.icon(
                            onPressed: () async {
                              if (controller
                                      .homeController.gullak.value.sikka >=
                                  5) {
                                Get.dialog(AlertDialog(
                                  alignment: Alignment.center,
                                  backgroundColor: Get.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  title: const Text("Don't have enough sikka "),
                                  content: const Text(
                                      'Please watch full rewarded ad to get 5 sikka'),
                                  actions: [
                                    OutlinedButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Back')),
                                    OutlinedButton(
                                        onPressed: () async {
                                          if (controller.homeController.user
                                                  .value.id !=
                                              null) {
                                            Get.back();
                                            await controller.downloadFile(
                                                controller.bookPath);
                                            controller
                                                .showInterstitialAd()
                                                .catchError((e) {});
                                            FirestoreData.updateSikka(
                                                uid: controller.homeController
                                                    .user.value.id!,
                                                increment: -3);
                                          }
                                        },
                                        child: const Text('Spend 3 Sikka')),
                                    OutlinedButton(
                                        onPressed: () {
                                          Get.back();
                                          if (controller
                                                  .rewardedInterstitialAd !=
                                              null) {
                                            controller.rewardedInterstitialAd
                                                ?.show(onUserEarnedReward:
                                                    (ad, reward) async {
                                              if (controller.homeController.user
                                                      .value.id !=
                                                  null) {
                                                await controller.downloadFile(
                                                    controller.bookPath);
                                                FirestoreData.updateSikka(
                                                    uid: controller
                                                        .homeController
                                                        .user
                                                        .value
                                                        .id!,
                                                    increment: reward.amount);
                                              }
                                            });
                                          } else {
                                            controller.downloadFile(
                                                controller.bookPath);
                                          }
                                        },
                                        child: const Text('Watch Rewarded Ad'))
                                  ],
                                ));
                              } else {
                                Get.dialog(AlertDialog(
                                  alignment: Alignment.center,
                                  backgroundColor: Get.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  title: const Text("Don't have enough sikka "),
                                  content: const Text(
                                      'Please watch full rewarded ad to get 5 sikka'),
                                  actions: [
                                    OutlinedButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Back')),
                                    OutlinedButton(
                                        onPressed: () {
                                          Get.back();
                                          if (controller
                                                  .rewardedInterstitialAd !=
                                              null) {
                                            controller.rewardedInterstitialAd
                                                ?.show(onUserEarnedReward:
                                                    (ad, reward) async {
                                              if (controller.homeController.user
                                                      .value.id !=
                                                  null) {
                                                await controller.downloadFile(
                                                    controller.bookPath);
                                                FirestoreData.updateSikka(
                                                    uid: controller
                                                        .homeController
                                                        .user
                                                        .value
                                                        .id!,
                                                    increment: reward.amount);
                                              }
                                            });
                                          } else {
                                            controller.downloadFile(
                                                controller.bookPath);
                                          }
                                        },
                                        child: const Text('Watch Rewarded Ad'))
                                  ],
                                ));
                              }
                            },
                            icon: const Icon(Icons.file_download),
                            label: Text(
                                '${(controller.received.value / 1048576).toStringAsFixed(1)}/${(controller.total.value / 1048576).toStringAsFixed(1)} MB'),
                          )
                    : OutlinedButton.icon(
                        onPressed: () {
                          controller.isLoading.value = true;
                          controller.chapter
                              .getDownloadURL()
                              .then((value) => controller.getdetails(value));
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      )
                : const Center(
                    child: CircularProgressIndicator(
                    strokeWidth: 6,
                  ))),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Downloading costs you 5 coins or instead watch a rewarded Ad ',
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
