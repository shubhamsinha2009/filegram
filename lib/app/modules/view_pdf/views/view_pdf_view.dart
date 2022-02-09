import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

import '../controllers/view_pdf_controller.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        titleTextStyle: const TextStyle(),
        //  title: Text(controller.ownerName,),
        title: ValueListenableBuilder<Object>(
            // The controller is compatible with ValueListenable<Matrix4> and you can receive notifications on scrolling and zooming of the view.
            valueListenable: controller.pdfController,
            builder: (context, value, child) {
              controller.currentPageNumber.value =
                  controller.pdfController.isReady
                      ? controller.pdfController.currentPageNumber
                      : 1;
              return Text(controller.pdfController.isReady
                  ? 'Page - ${controller.pdfController.currentPageNumber}/${controller.pdfController.pageCount}'
                  : 'Page -');
            }),
        actions: <Widget>[
          CachedNetworkImage(
            imageUrl: controller.photoUrl,
          ),
        ],
      ),
      body: PdfViewer.openFile(
        Get.arguments,
        viewerController: controller.pdfController,
        onError: (err) => Get.snackbar('Error', err.toString()),
        params: PdfViewerParams(
          padding: 5,
          minScale: 1.0,
          pageNumber: controller.intialPageNumber,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
