import 'dart:async';
import 'dart:io';

import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';

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
    try {
      bool? _isEncDone;
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
      return _isEncDone ?? false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onInit() async {
    filePath = Get.arguments;
    fileOut = '${(await getTemporaryDirectory()).path}/_';
    try {
      isDecryptionDone.value = await doDecryption(filePath);
    } catch (e) {
      Get.dialog(
        AlertDialog(
          alignment: Alignment.center,
          backgroundColor: Colors.black,
          title: const Icon(Icons.error_outline),
          content: Text(
            e.toString(),
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
    }

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
    if (File(fileOut).existsSync()) {
      await File(fileOut).delete();
    }

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
