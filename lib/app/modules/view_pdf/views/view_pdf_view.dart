import 'package:flutter/material.dart';
import 'package:flutter_pdfview_professor/flutter_pdfview_professor.dart';
import 'package:get/get.dart';

import '../controllers/view_pdf_controller.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() => controller.isDecryptionDone.isFalse
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: controller.fileOut,
              // pdfData: ,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: false,
              pageSnap: false,
              nightMode: false,
              fitEachPage: true,
              fitPolicy: FitPolicy.WIDTH,
              defaultPage: controller.intialPageNumber,

              onRender: (_pages) {
                controller.pages = _pages;
                controller.isReady.value = true;
              },
              onError: (error) {
                Get.dialog(
                  AlertDialog(
                    alignment: Alignment.center,
                    backgroundColor: Colors.black,
                    title: const Icon(Icons.error_outline),
                    content: Text(
                      '${error.toString()} ',
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
                  messageText:
                      Text('The Page $page has an error : ${error.toString()}'),
                  icon: const Icon(Icons.error_outline),
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3),
                ));
              },
              onViewCreated: (PDFViewController pdfViewController) {
                controller.pdfController.complete(pdfViewController);
              },

              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  controller.currentPageNumber.value = page;
                } //  print('page change: /');
              },
            )),
    );
  }
}
