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
        ],
      ),
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
      body: Obx(() => controller.isLoding.isFalse
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
                  return ListTile(
                    title: Text(controller.book
                        .chapterNames[controller.getListViewItemIndex(index)]),

                    // leading: Text('${index + 1}'),
                    onTap: () async {
                      String _bookPath =
                          '${await controller.filesDocDir()}/${controller.book.ncertDirectLinks[controller.getListViewItemIndex(index)]}.pdf';
                      if (await File(_bookPath).exists()) {
                        controller.showInterstitialAd().catchError((e) {});
                        Get.toNamed(Routes.viewPdf,
                            arguments: [_bookPath, false]);
                      } else {
                        controller
                            .getdetails(
                                'https://ncert.nic.in/textbook/pdf/${controller.book.ncertDirectLinks[controller.getListViewItemIndex(index)]}.pdf')
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
    );
  }
}
