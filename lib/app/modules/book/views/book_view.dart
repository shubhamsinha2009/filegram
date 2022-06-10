import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/book_controller.dart';
import 'widgets/btmsheet.dart';

class BookView extends GetView<BookController> {
  const BookView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => controller.isLoding.isFalse
              ? Text(
                  '${controller.book.bookName} ${controller.book.classNumber}')
              : const Text('Loading Book Name ...'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.changeThemeMode(
                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                controller.homeController.changeTheme.toggle();
              },
              icon: Icon(
                controller.homeController.changeTheme.isTrue
                    ? Icons.light_mode
                    : Icons.dark_mode,
              )),
          IconButton(
              onPressed: () {
                Get.showSnackbar(GetSnackBar(
                  backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                  title: 'How to delete file chapter fom device ?',
                  message: 'Just Long Press on Chapter to delete',
                  duration: const Duration(seconds: 5),
                ));
              },
              icon: const Icon(Icons.info)),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     child: const Icon(Icons.info),
      //     onPressed: () {
      //       Get.showSnackbar(GetSnackBar(
      //         backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
      //         title: 'How to delete file chapter fom device ?',
      //         message: 'Just Long Press on Chapter to delete',
      //         duration: const Duration(seconds: 5),
      //       ));
      //     }),
      bottomNavigationBar: Obx(() => controller.isBottomBannerAdLoaded.isTrue
          ? SizedBox(
              height: controller.bottomBannerAd.size.height.toDouble(),
              width: controller.bottomBannerAd.size.width.toDouble(),
              child: controller.adWidget(ad: controller.bottomBannerAd),
            )
          : const SizedBox(
              height: 0,
              width: 0,
            )),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        backgroundColor: Colors.white,
        color: Colors.black87,
        strokeWidth: 4,
        displacement: 150,
        edgeOffset: 0,
        onRefresh: () async {
          controller.onInitialisation(isCache: false);
        },
        child: Obx(() => controller.isLoding.isFalse
            ? ListView.builder(
                itemCount: controller.book.chapterNames.length +
                    (controller.isInlineBannerAdLoaded.isTrue &&
                            (controller.book.chapterNames.length >=
                                controller.inlineAdIndex)
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (controller.isInlineBannerAdLoaded.isTrue &&
                      index == controller.inlineAdIndex &&
                      (controller.book.chapterNames.length >=
                          controller.inlineAdIndex)) {
                    return Container(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      width: controller.inlineBannerAd.size.width.toDouble(),
                      height: controller.inlineBannerAd.size.height.toDouble(),
                      child: controller.adWidget(ad: controller.inlineBannerAd),
                    );
                  } else {
                    String _bookPath =
                        '${controller.pathDir}/${(controller.book.chapterLinks[controller.getListViewItemIndex(index)]).split("/").last}';
                    return ListTile(
                      onLongPress: (() => File(_bookPath).existsSync()
                          ? Get.dialog(
                              AlertDialog(
                                backgroundColor: Get.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                title: Text(
                                  'Are you sure you wish to delete ${controller.book.chapterNames[controller.getListViewItemIndex(index)]}?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      if (Get.isOverlaysOpen) {
                                        Get.back();
                                      }
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (Get.isOverlaysOpen) {
                                        Get.back();
                                      }
                                      File(_bookPath).delete().then((value) =>
                                          Get.showSnackbar(GetSnackBar(
                                            backgroundColor: Get.theme
                                                .snackBarTheme.backgroundColor!,
                                            messageText: const Text('Deleted'),
                                            icon: const Icon(
                                                Icons.delete_forever_rounded),
                                            snackPosition: SnackPosition.TOP,
                                            duration:
                                                const Duration(seconds: 3),
                                          )));
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                              barrierDismissible: false,
                            )
                          : Get.showSnackbar(GetSnackBar(
                              backgroundColor:
                                  Get.theme.snackBarTheme.backgroundColor!,
                              title: 'Already deleted',
                              message: 'Tap to download',
                              duration: const Duration(seconds: 5),
                            ))),

                      title: Text(controller.book.chapterNames[
                          controller.getListViewItemIndex(index)]),

                      // leading: Text('${index + 1}'),
                      onTap: () {
                        if (File(_bookPath).existsSync()) {
                          controller.showInterstitialAd().catchError((e) {});
                          Get.toNamed(Routes.viewPdf,
                              arguments: [_bookPath, false]);
                        } else {
                          controller
                              .getdetails(controller.book.chapterLinks[
                                  controller.getListViewItemIndex(index)])
                              .then((value) => Get.bottomSheet(
                                    DownloadBtmSheet(
                                      controller: controller,
                                      filePath: _bookPath,
                                      index: index,
                                    ),
                                    isScrollControlled: true,
                                  ));
                        }
                      },
                    );
                  }
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              )),
      ),
    );
  }
}
