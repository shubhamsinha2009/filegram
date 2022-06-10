import 'package:flutter/material.dart';
import 'package:flutter_pdfview_professor/flutter_pdfview_professor.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/view_pdf_controller.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Chip(
              label: Text(
                'Ad in ${controller.countdownTimer.value} sec',
                softWrap: true,
              ),
            )),
        // Obx(() => Text(
        //               "${controller.currentPageNumber + 1}/${controller.pages}")),
        // Text("${controller.currentPageNumber + 1}/${controller.pages}")),
        actions: [
          //  Obx(() => Text('${controller.countdownTimer.value}')),
          IconButton(
              onPressed: () async => await Share.shareFiles(
                    [controller.filePath],
                    text:
                        'Download Filegram to open this file 🔓- https://play.google.com/store/apps/details?id=com.sks.filegram',
                  ),
              icon: const Icon(Icons.share)),
          IconButton(
              onPressed: () {
                Get.changeThemeMode(
                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                Get.find<HomeController>().changeTheme.toggle();
              },
              icon: const Icon(Icons.settings_display_rounded)),
          IconButton(
              onPressed: () {
                controller.swipehorizontal.toggle();
              },
              icon: const Icon(Icons.rotate_90_degrees_ccw_outlined)),
        ],
      ),

      bottomNavigationBar: Obx(() => controller.isBottomBannerAdLoaded.isTrue
          ? SizedBox(
              height: 50,
              width: 320,
              child: controller.adWidget(ad: controller.bottomBannerAd),
            )
          : SizedBox(
              height: 50,
              width: 320,
              child: Text(
                controller.filePath.split('/').last,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            )),
      //top: false,
      body: Obx(
        () => controller.isDecryptionDone.isFalse
            ? Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  fit: BoxFit.fill,
                ),
              )
            : PDFView(
                key: GlobalKey(),
                filePath: controller.fileOut,
                // pdfData: File(controller.fileOut).readAsBytesSync(),
                enableSwipe: true,
                swipeHorizontal: controller.swipehorizontal.value,
                autoSpacing: false,
                pageFling: false,

                pageSnap: false,
                nightMode: Get.find<HomeController>().changeTheme.value,
                fitEachPage: true,
                fitPolicy: FitPolicy.WIDTH,
                defaultPage: controller.intialPageNumber,
                onRender: (_pages) {
                  controller.isReady.value = true;
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
                              Get.back(closeOverlays: true, canPop: true);
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
                    backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                    messageText: Text(
                        'The Page $page has an error : ${error.toString()}'),
                    icon: const Icon(Icons.error_outline),
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 3),
                  ));
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  // controller.pdfController.complete(pdfViewController);
                },

                onPageChanged: (int? page, int? total) {
                  if (page != null && total != null) {
                    controller.intialPageNumber = page;
                    controller.currentPageNumber.value = page;
                    controller.pages.value = total;
                  } //  print('page change: /');
                },
              ),
      ),
    );
  }
}
