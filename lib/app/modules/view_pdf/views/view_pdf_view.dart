import 'package:alh_pdf_view/lib.dart';
import 'package:filegram/app/modules/no_internet/views/no_internet_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/view_pdf_controller.dart';

import 'widgets/bookmark.dart';
import 'widgets/bottombar.dart';

import 'widgets/hiddenappbar.dart';
import 'widgets/nextpage.dart';
import 'widgets/previouspage.dart';
import 'widgets/toggleappbar.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isInternetConnected.isTrue
        ? SafeArea(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(alignment: Alignment.center, children: [
                Obx(() => controller.isDecryptionDone.isFalse
                    ? Center(
                        child: Lottie.asset(
                          'assets/loading.json',
                          fit: BoxFit.fill,
                        ),
                      )
                    : AlhPdfView(
                        key: ValueKey(controller.changeTheme.value),
                        filePath: controller.fileOut,

                        // pdfData: File(controller.fileOut).readAsBytesSync(),
                        enableSwipe: true,
                        swipeHorizontal: true,
                        autoSpacing: true,
                        pageFling: true,
                        pageSnap: true,
                        nightMode: controller.changeTheme.value,
                        fitEachPage: true,
                        fitPolicy: FitPolicy.both,
                        defaultPage: controller.intialPageNumber,
                        minZoom: 0.5,
                        maxZoom: 5,
                        enableDefaultScrollHandle: false,

                        enableDoubleTap: true,

                        onRender: (pages) {
                          controller.totalPages.value = pages;
                        },
                        onError: (error) {
                          Get.dialog(
                            AlertDialog(
                              alignment: Alignment.center,
                              backgroundColor:
                                  Get.isDarkMode ? Colors.black : Colors.white,
                              title: const Icon(Icons.error_outline),
                              content: Text(
                                error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    if (Get.isOverlaysOpen) {
                                      Get.back(
                                          closeOverlays: true, canPop: true);
                                    }
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                            barrierDismissible: false,
                          );
                        },
                        onPageError: (page, error) {
                          Get.showSnackbar(GetSnackBar(
                            backgroundColor:
                                Get.theme.snackBarTheme.backgroundColor!,
                            messageText: Text(
                                'The Page $page has an error : ${error.toString()}'),
                            icon: const Icon(Icons.error_outline),
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 3),
                          ));
                        },
                        onViewCreated:
                            (AlhPdfViewController pdfViewController) {
                          // controller.pdfController.complete(pdfViewController);
                          Get.put(ViewPdfController()).pdfViewController =
                              pdfViewController;
                        },

                        onPageChanged: (int? page, int? total) {
                          if (page != null && total != null) {
                            controller.intialPageNumber = page;
                            controller.currentPage.value = page;
                            controller.pageTimer = 0;
                            //  controller.lastChanged = controller.pageTimer;
                          }

                          ///  print('page change: /');
                        },
                      )),
                BookMark(controller: controller),
                NextPage(controller: controller),
                PreviousPage(controller: controller),
                ToggleAppBar(controller: controller),
                HiddenAppBar(controller: controller),
                BottomBar(controller: controller)
              ]),
            ),
          )
        : const NoInternetView());
  }
}
