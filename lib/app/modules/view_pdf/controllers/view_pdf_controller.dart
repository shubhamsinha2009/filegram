import 'dart:io';

import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';

import 'package:pdf_render/pdf_render_widgets.dart';

class ViewPdfController extends GetxController {
  late final PdfViewerController pdfController;
  late final String filePath;
  final currentPageNumber = 1.obs;
  late final int intialPageNumber;
  late final String photoUrl;
  late final String ownerName;
  late File file;

  @override
  void onInit() {
    filePath = Get.arguments;
    final Map<String, dynamic>? _pdfDetails =
        GetStorageDbService.getRead(key: filePath);
    intialPageNumber = _pdfDetails?['intialPageNumber'] ?? 1;
    photoUrl = _pdfDetails?['photoUrl'] ?? 'https://source.unsplash.com/random';
    ownerName = _pdfDetails?['ownerName'] ?? 'Unknown';
    pdfController = PdfViewerController();

    super.onInit();
  }

  @override
  void onReady() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

    super.onReady();
  }

  @override
  void onClose() async {
    File(filePath).deleteSync();
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    final Map<String, dynamic> _pdfDetails = {
      'photoUrl': photoUrl,
      'ownerName': ownerName,
      'intialPageNumber': currentPageNumber.value
    };
    GetStorageDbService.getWrite(key: filePath, value: _pdfDetails);
    pdfController.dispose();
  }
}
