import 'dart:async';
import 'dart:io';

import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/provider/firestore_data.dart';
import '../../encrypt_decrypt/services/file_encrypter.dart';
import '../../home/controllers/home_controller.dart';

class ViewPdfController extends GetxController {
  final swipehorizontal = false.obs;
  final nightmode = false.obs;
  final pages = 1.obs;
  final isReady = false.obs;
  final isDecryptionDone = false.obs;
  final isVisible = true.obs;
  late final String filePath;
  final currentPageNumber = 0.obs;
  late int intialPageNumber;
  late final String photoUrl;
  late final String ownerName;
  late File file;
  late String fileOut;
  String? sourceUrl;
  Future<bool> doDecryption(
    String _fileIn,
  ) async {
    bool? _isEncDone;
    try {
      final _checkKey = await FileEncrypter.getFileIv(inFilename: _fileIn);
      if (_checkKey != null) {
        final _document = await FirestoreData.getSecretKey(
          _checkKey,
          Get.find<HomeController>().user.value.emailId,
          Get.find<HomeController>().user.value.id,
        );
        final _secretKey = _document?.secretKey;
        if (_secretKey != null) {
          _isEncDone = await FileEncrypter.decrypt(
            inFilename: _fileIn,
            key: _secretKey,
            outFileName: fileOut,
          );
        }
        await FirestoreData.updateViews(_document?.documentId);

        sourceUrl = _document?.sourceUrl;
      }
    } on PlatformException catch (e) {
      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 5),
        messageText: Text(e.message ?? e.details),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
      ));
    }
    return _isEncDone ?? false;
  }

  @override
  void onInit() async {
    filePath = Get.arguments;
    fileOut = '${(await getTemporaryDirectory()).path}/current.pdf';

    isDecryptionDone.value = await doDecryption(filePath);

    final Map<String, dynamic>? _pdfDetails =
        GetStorageDbService.getRead(key: filePath);
    intialPageNumber = _pdfDetails?['intialPageNumber'] ?? 0;
    photoUrl = _pdfDetails?['photoUrl'] ?? 'https://source.unsplash.com/random';
    ownerName = _pdfDetails?['ownerName'] ?? 'Unknown';
    sourceUrl = _pdfDetails?['sourceUrl'];

    super.onInit();
  }

  @override
  void onReady() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

    super.onReady();
  }

  @override
  void onClose() async {
    await File(fileOut).delete();
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    final Map<String, dynamic> _pdfDetails = {
      'photoUrl': photoUrl,
      'ownerName': ownerName,
      'intialPageNumber': currentPageNumber.value,
      'sourceUrl': sourceUrl,
    };
    GetStorageDbService.getWrite(key: filePath, value: _pdfDetails);
  }
}
