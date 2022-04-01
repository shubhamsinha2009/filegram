import 'dart:io';
import 'dart:math';
import 'package:filegram/app/controller/interstitial_ads_controller.dart';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/firebase_analytics.dart';
import '../../../data/model/documents_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/controllers.dart';
import '../services/file_encrypter.dart';

class EncryptDecryptController extends GetxController {
  final isLoading = false.obs;
  final _documentModel = DocumentModel().obs;
  final analytics = AnalyticsService.analytics;
  final homeController = Get.find<HomeController>();
  final interstitialAdController = Get.put(InterstitialAdsController());

  Future<void> pickFile() async {
    try {
      isLoading.toggle();
      final String? _result = await FlutterFileDialog.pickFile(
          params: const OpenFileDialogParams(
        copyFileToCacheDir: true,
        fileExtensionsFilter: ['pdf', 'enc'],
        mimeTypesFilter: ['application/pdf', 'application/octet-stream'],
      ));
      // pickedFile = _result;
      // Picked File variable
      isLoading.toggle();
      confirmDialog(_result);
    } on PlatformException catch (e) {
      isLoading.toggle();
      Get.showSnackbar(GetSnackBar(
        messageText: Text(e.message ?? e.details),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  void confirmDialog(String? pickedFile) {
    final _result = pickedFile;
    if (_result != null) {
      String _fileName = _result.split('/').last;
      final String _dialogTitle =
          _result.contains('.enc') ? 'decrypt' : 'encrypt';
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
                  await interstitialAdController.showInterstitialAd();
                  bool? _isEncDone = await encryptDecrypt(pickedFile);
                  if (_isEncDone != null && _isEncDone) {
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

  Future<bool?> encryptDecrypt(String? pickedFile) async {
    final _result = pickedFile;
    bool? _isEncDone;
    if (_result != null) {
      try {
        if (_result.contains('.enc')) {
          _isEncDone = await doFileCopy(_result);
        } else {
          _isEncDone = await doEncryption(_isEncDone, _result);
        }

        // Get.dialog(
        //   WillPopScope(
        //     onWillPop: () async => false,
        //     child: AlertDialog(
        //       backgroundColor: Colors.black,
        //       title: const Text('Reward : Want to Save your file? '),
        //       // title: const Text('Want to Save your file? '),
        //       content: Text(
        //           'Your File : $_filename will be Saved as a reward after you watch full ad'),
        //       // content: Text(
        //       //     'Your File : ${_fileOut.split('/').last} will be Saved'),
        //       actions: <Widget>[
        //         TextButton(
        //           onPressed: () {
        //             if (File(_fileOut).existsSync()) {
        //               File(_fileOut).deleteSync();
        //             }
        //             if (Get.isOverlaysOpen) {
        //               Get.back();
        //             }
        //             Get.showSnackbar(
        //               const GetSnackBar(
        //                 messageText: Text('File Saving Cancelled '),
        //                 duration: Duration(seconds: 3),
        //                 snackPosition: SnackPosition.TOP,
        //               ),
        //             );
        //           },
        //           child: const Text('Cancel'),
        //         ),
        //         TextButton(
        //           onPressed: () async {
        //             isLoading.toggle();
        //             if (Get.isOverlaysOpen) {
        //               Get.back();
        //             }
        // rewardedAdController.rewardedAd.show(
        //   onUserEarnedReward: (ad, reward) {
        //     saveFile();
        //   },
        // ).whenComplete(() => isLoading.toggle());
        //           },
        //           child: const Text('Save File'),
        //         ),
        //       ],
        //     ),
        //   ),
        //   barrierDismissible: false,
        // );

      } catch (e) {
        isLoading.toggle();
        Get.showSnackbar(GetSnackBar(
          messageText: Text(e.toString()),
          icon: const Icon(Icons.error_outline),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        ));
      }
      if (File(_result).existsSync()) {
        File(_result).deleteSync();
      }
      isLoading.toggle();
    }

    return _isEncDone;
  }

  Future<String> filesDocDir() async {
    //Get this App Document Directory
    //App Document Directory + folder name

    final Directory? _appDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory('${_appDocDir?.path}/Files');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  Future<bool?> doEncryption(bool? _isEncDone, String _result) async {
    try {
      String _fileOut = '$_result.enc';
      String _filename = _fileOut.split('/').last;
      _fileOut = '${await filesDocDir()}/$_filename';
      final secretKey = await FileEncrypter.generatekey();
      final iv = await FileEncrypter.generateiv();
      if (secretKey != null && iv != null) {
        _isEncDone = await FileEncrypter.encrypt(
          key: secretKey,
          iv: iv,
          inFilename: _result,
          outFileName: _fileOut,
        );
      }
      final _userId = homeController.user.value.id;
      final _fizeSize = getFileSize(bytes: File(_result).lengthSync());
      final _ownerName = homeController.user.value.name;
      final _ownerPhotoUrl = homeController.user.value.photoUrl;
      final _ownerEmailId = homeController.user.value.emailId;
      final _documentReference =
          await FirestoreData.createDocument(_documentModel(DocumentModel(
        documentName: _result.split('/').last,
        secretKey: secretKey,
        iv: iv,
        ownerId: _userId,
        documentSize: _fizeSize,
        ownerName: _ownerName,
        ownerPhotoUrl: _ownerPhotoUrl,
        ownerEmailId: _ownerEmailId,
      )));
      // await FirestoreData.getDocumentsListFromServer(_userId);
      _documentModel(await FirestoreData.getDocument(_documentReference));
      await FirestoreData.createViewsAndUsers(_documentModel.value.documentId);
      final Map<String, dynamic> _pdfDetails = {
        'photoUrl': _ownerPhotoUrl,
        'ownerName': _ownerName,
        'intialPageNumber': 0,
      };
      GetStorageDbService.getWrite(key: _fileOut, value: _pdfDetails);
      return _isEncDone;
    } on PlatformException {
      isLoading.value = false;
      rethrow;
      // Get.showSnackbar(GetSnackBar(
      //   duration: const Duration(seconds: 5),
      //   messageText: Text(e.toString()),
      //   icon: const Icon(Icons.error_outline),
      //   snackPosition: SnackPosition.TOP,
      // ));
    }
  }

  Future<bool> doFileCopy(
    String _result,
  ) async {
    try {
      // _fileOut = '${await filesDocDir()}/$_filename';
      final _checkKey = await FileEncrypter.getFileIv(inFilename: _result);
      if (_checkKey != null) {
        final _document = await FirestoreData.getSecretKey(
          _checkKey,
          homeController.user.value.emailId,
          homeController.user.value.id,
        );
        final _secretKey = _document?.secretKey;
        if (_secretKey != null) {
          String _fileOut = '${await filesDocDir()}/${_document?.documentName}';
          await File(_result).copy(_fileOut);

          await FirestoreData.updateViewsUsers(_document?.documentId);

          final Map<String, dynamic> _pdfDetails = {
            'photoUrl': _document?.ownerPhotoUrl,
            'ownerName': _document?.ownerName,
            'intialPageNumber': 0,
          };
          GetStorageDbService.getWrite(key: _fileOut, value: _pdfDetails);
          return true;
        }
        return false;
        // ! Use of Cloud Function
        // *Using Cloud Firestore temporarily
      }
      return false;
    } on PlatformException {
      isLoading.value = false;
      rethrow;
      // Get.showSnackbar(GetSnackBar(
      //   duration: const Duration(seconds: 5),
      //   messageText: Text(e.message ?? e.details),
      //   icon: const Icon(Icons.error_outline),
      //   snackPosition: SnackPosition.TOP,
      // ));
    }
  }

  // Future<void> saveFile() async {
  //   if (pickedFile != null) {
  //     String? _fileSavedPath;
  //     final String _fileOut = pickedFile!;

  //     try {
  //       final params = SaveFileDialogParams(sourceFilePath: _fileOut);
  //       _fileSavedPath = await FlutterFileDialog.saveFile(params: params);

  //       if (_fileSavedPath != null && _fileOut.endsWith('.enc')) {}

  //       if (File(_fileOut).existsSync()) {
  //         File(_fileOut).deleteSync();
  //       }
  //       if (File(_fileOut + '.enc').existsSync()) {
  //         File(_fileOut + '.enc').deleteSync();
  //       }
  //       if (File(_fileOut.replaceAll('.enc', '').trim()).existsSync()) {
  //         File(_fileOut.replaceAll('.enc', '').trim()).deleteSync();
  //       }

  //       if (_fileSavedPath != null) {
  //         Get.showSnackbar(
  //           const GetSnackBar(
  //             messageText: Text('File Saved '),
  //             duration: Duration(seconds: 3),
  //             snackPosition: SnackPosition.TOP,
  //           ),
  //         );
  //       } else {
  //         Get.showSnackbar(
  //           const GetSnackBar(
  //             messageText: Text('File Not Saved '),
  //             duration: Duration(seconds: 3),
  //             snackPosition: SnackPosition.TOP,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       Get.showSnackbar(GetSnackBar(
  //         duration: const Duration(seconds: 5),
  //         messageText: Text(e.toString()),
  //         icon: const Icon(Icons.error_outline),
  //         snackPosition: SnackPosition.TOP,
  //       ));
  //     }
  //   }
  // }
  // String getSubtitle({required int bytes, required DateTime time}) {
  //   if (bytes <= 0) return "0 B";
  //   const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  //   var i = (log(bytes) / log(1024)).floor();
  //   return '${DateFormat.yMMMMd('en_US').add_jm().format(time)} - ${((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i]}';
  // }

  String getFileSize({
    required int bytes,
  }) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }
}
