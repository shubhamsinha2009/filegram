import 'package:flutter/material.dart';
import 'package:flutter_pdfview_professor/flutter_pdfview_professor.dart';
import 'package:get/get.dart';

import '../controllers/view_pdf_controller.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // appBar: AppBar(),
      // floatingActionButton: FutureBuilder<PDFViewController>(
      //   future: controller.pdfController.future,
      //   builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
      //     if (snapshot.hasData) {
      //       return FloatingActionButton.extended(
      //         label: Text("Go to ${controller.pages! ~/ 2}"),
      //         onPressed: () async {
      //           await snapshot.data!.setPage(controller.pages! ~/ 2);
      //         },
      //       );
      //     }

      //     return Container();
      //   },
      // ),
      child: PDFView(
        filePath: controller.filePath,
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
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          controller.pdfController.complete(pdfViewController);
        },
        onPageChanged: (int? page, int? total) {
          if (page != null) {
            controller.currentPageNumber.value = page;
          }

          //  print('page change: $page/$total');
        },
      ),
    );
  }
}
