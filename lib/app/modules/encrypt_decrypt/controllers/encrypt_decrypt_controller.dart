import 'dart:io';

import 'package:filegram/app/core/services/firebase_analytics.dart';
import 'package:filegram/app/data/model/documents_model.dart';
import 'package:filegram/app/data/model/user_model.dart';
import 'package:filegram/app/data/provider/firestore_data.dart';
import 'package:filegram/app/modules/encrypt_decrypt/services/file_encrypter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';

class EncryptDecryptController extends GetxController {
  final isLoading = false.obs;
  String? pickedFile;
  final _documentModel = DocumentModel().obs;
  final analytics = AnalyticsService.analytics;
  final user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final firestoreData = FirestoreData();

  Future<void> pickFile() async {
    try {
      isLoading.toggle();
      final String? _result = await FlutterFileDialog.pickFile();
      pickedFile = _result;
    } on PlatformException catch (e) {
      Get.showSnackbar(GetSnackBar(
        messageText: Text(e.message ?? e.details),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
      ));
    } finally {
      isLoading.toggle();
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
        WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Want to $_dialogTitle your file ?',
            ),
            content: Text('Your File : $_fileName will be ${_dialogTitle}ed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (File(_result).existsSync()) {
                    File(_result).deleteSync();
                  }
                  if (Get.isOverlaysOpen) {
                    Get.back();
                  }
                  Get.showSnackbar(
                    GetSnackBar(
                      message: 'File ${_dialogTitle}ion Canceled',
                      // backgroundColor: Colors.amber,
                      duration: const Duration(seconds: 3),
                      snackPosition: SnackPosition.TOP,
                    ),
                  );
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  isLoading.toggle();
                  if (Get.isOverlaysOpen) {
                    Get.back();
                  }
                  await encryptDecrypt();

                  // if (!interstitialAd.isAvailable) {
                  //   await interstitialAd.load();
                  //   await encryptDecrypt();
                  // } else {
                  //   interstitialAd.show();
                  // }
                },
                child: Text(_dialogTitle.toUpperCase()),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> encryptDecrypt() async {
    final _result = pickedFile;
    bool? _isEncDone;

    if (_result != null) {
      String _fileOut = _result.endsWith('.enc')
          ? _result.replaceAll('.enc', '').trim()
          : '$_result.enc';
      pickedFile = _fileOut;

      try {
        if (_result.endsWith('.enc')) {
          _isEncDone = await doDecryption(_result, _isEncDone, _fileOut);
        } else {
          _isEncDone = await doEncryption(_fileOut, _isEncDone, _result);
        }
      } catch (e) {
        Get.showSnackbar(GetSnackBar(
          messageText: Text(e.toString()),
          icon: const Icon(Icons.error_outline),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        ));
      } finally {
        if (File(_result).existsSync()) {
          File(_result).deleteSync();
        }
        if (_isEncDone != null && _isEncDone) {
          isLoading.toggle();

          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                backgroundColor: Colors.black,
                title: const Text('Reward : Want to Save your file? '),
                content: Text(
                    'Your File : ${_fileOut.split('/').last} will be Saved as a reward after you watch full ad'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (File(_fileOut).existsSync()) {
                        File(_fileOut).deleteSync();
                      }
                      if (Get.isOverlaysOpen) {
                        Get.back();
                      }
                      Get.showSnackbar(
                        const GetSnackBar(
                          messageText: Text('File Saving Cancelled '),
                          duration: Duration(seconds: 3),
                          snackPosition: SnackPosition.TOP,
                        ),
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      isLoading.toggle();
                      if (Get.isOverlaysOpen) {
                        Get.back();
                      }
                      await saveFile();
                      // if (!rewardedInterstitial.isAvailable) {
                      //   await rewardedInterstitial.load();
                      //   await saveFile();
                      // } else {
                      //   await rewardedInterstitial.show();
                      // }
                    },
                    child: const Text('Save File'),
                  ),
                ],
              ),
            ),
            barrierDismissible: false,
          );
        }
      }
    }
  }

  Future<bool?> doEncryption(
    String _fileOut,
    bool? _isEncDone,
    String _result,
  ) async {
    final _secretKey = await FileEncrypter.generatekey();
    final _iv = await FileEncrypter.generateiv();
    final _userId = auth.currentUser?.uid;

    if (_secretKey != null && _iv != null) {
      _isEncDone = await FileEncrypter.encrypt(
        key: _secretKey,
        iv: _iv,
        inFilename: _result,
        outFileName: _fileOut,
      );
      await FirestoreData.createDocument(_documentModel(DocumentModel(
        documentName: _fileOut.split('/').last,
        secretKey: _secretKey,
        iv: _iv,
        ownerId: _userId,
      )));
    }
    return _isEncDone;
  }

  Future<bool?> doDecryption(
    String _result,
    bool? _isEncDone,
    String _fileOut,
  ) async {
    final _checkKey = await FileEncrypter.getFileIv(inFilename: _result);
    if (_checkKey != null) {
      final _document = await FirestoreData.getSecretKey(_checkKey);
      final _secretKey = _document?.secretKey;
      if (_secretKey != null) {
        _isEncDone = await FileEncrypter.decrypt(
          inFilename: _result,
          key: _secretKey,
          outFileName: _fileOut,
        );
      }
    }
    return _isEncDone;
  }

  Future<void> saveFile() async {
    if (pickedFile != null) {
      String? _fileSavedPath;
      final String _fileOut = pickedFile!;
      try {
        final params = SaveFileDialogParams(sourceFilePath: _fileOut);
        _fileSavedPath = await FlutterFileDialog.saveFile(params: params);
      } catch (e) {
        Get.showSnackbar(GetSnackBar(
          duration: const Duration(seconds: 5),
          messageText: Text(e.toString()),
          icon: const Icon(Icons.error_outline),
          snackPosition: SnackPosition.TOP,
        ));
      } finally {
        isLoading.toggle();
        if (File(_fileOut).existsSync()) {
          File(_fileOut).deleteSync();
        }
        if (File(_fileOut + '.enc').existsSync()) {
          File(_fileOut + '.enc').deleteSync();
        }
        if (File(_fileOut.replaceAll('.enc', '').trim()).existsSync()) {
          File(_fileOut.replaceAll('.enc', '').trim()).deleteSync();
        }
        if (_fileSavedPath != null) {
          Get.showSnackbar(
            const GetSnackBar(
              messageText: Text('File Saved '),
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
            ),
          );
        } else {
          Get.showSnackbar(
            const GetSnackBar(
              messageText: Text('File Not Saved '),
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
            ),
          );
        }
      }
    }
  }

  @override
  void onInit() async {
    if (auth.currentUser?.uid != null) {
      final String _uid = auth.currentUser?.uid ?? '';
      user(await firestoreData.getUser(_uid));

      super.onInit();
    }
  }
}
