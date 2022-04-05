import 'package:flutter/material.dart';
import 'package:flutter_pdfview_professor/flutter_pdfview_professor.dart';
import 'package:get/get.dart';

import '../controllers/view_pdf_controller.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text("${controller.currentPageNumber + 1}/${controller.pages}")),
        actions: [
          IconButton(
              onPressed: () => controller.nightmode.toggle(),
              icon: const Icon(Icons.settings_display_rounded)),
          IconButton(
              onPressed: () {
                controller.swipehorizontal.toggle();
              },
              icon: const Icon(Icons.rotate_90_degrees_ccw_outlined)),
        ],
      ),
      //top: false,
      body: Obx(
        () => controller.isDecryptionDone.isFalse
            ? const Center(child: CircularProgressIndicator())
            : PDFView(
                key: GlobalKey(),
                filePath: controller.fileOut,
                // pdfData: ,
                enableSwipe: true,
                swipeHorizontal: controller.swipehorizontal.value,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                nightMode: controller.nightmode.value,
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
                      backgroundColor: Colors.black,
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
                    controller.intialPageNumber =
                        controller.currentPageNumber.value = page;
                    controller.pages.value = total;
                  } //  print('page change: /');
                },
              ),
      ),
    );
  }
}
