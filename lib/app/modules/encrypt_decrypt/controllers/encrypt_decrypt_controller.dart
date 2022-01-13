import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';

class EncryptDecryptController extends GetxController {
  final _isLoading = false.obs;
  get isLoading => _isLoading.value;
  set isLoading(value) => _isLoading.value = value;
  String? pickedFile;

  Future<void> chooseFiles() async {
    try {
      _isLoading.value = true;
      final String? _result = await FlutterFileDialog.pickFile(
        params: const OpenFileDialogParams(
            copyFileToCacheDir: true, allowEditing: true),
      );
      pickedFile = _result;
    } on PlatformException catch (e) {
      Get.dialog(AlertDialog(
        backgroundColor: Colors.black,
        title: Text(e.details),
        content: Row(
          children: [
            Text(e.message ?? e.code),
            const Icon(Icons.error_outline),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (Get.isDialogOpen != null && Get.isDialogOpen!) {
                Get.back();
              }
            },
          ),
        ],
      ));
    } finally {
      _isLoading.value = false;

      confirmDialog();
    }
  }

  void confirmDialog() {
    final _result = pickedFile;
    if (_result != null) {
      String _fileName = _result.split('/').last;
      final String _dialogTitle =
          _result.endsWith('.enc') ? 'decrypt' : 'encrypt';
      Get.dialog(
        // barrierDismissible: false,

        //  onWillPop: () async => false,
        AlertDialog(
          // barrierDismissible: false,

          backgroundColor: Colors.black,
          title: Text('Want to $_dialogTitle your file ? '),
          content: Text('Your File : $_fileName will be ${_dialogTitle}ed'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (File(_result).existsSync()) {
                  File(_result).deleteSync();
                }
                if (Get.isDialogOpen != null && Get.isDialogOpen!) {
                  Get.back();
                }
                Get.showSnackbar(GetSnackBar(
                  message: 'File ${_dialogTitle}ion Canceled ',
                  backgroundColor: Colors.amber,
                ));
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                _isLoading.value = true;

                if (Get.isDialogOpen != null && Get.isDialogOpen!) {
                  Get.back();
                }
                // await encryptDecrypt();
              },
              child: Text(_dialogTitle.toUpperCase()),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
}
