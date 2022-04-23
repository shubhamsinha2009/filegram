import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:filegram/app/controller/interstitial_ads_controller.dart';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:open_as_default/open_as_default.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/firebase_analytics.dart';
import '../../../data/model/documents_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/controllers.dart';
import '../services/file_encrypter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class EncryptDecryptController extends GetxController {
  final isLoading = false.obs;
  final _documentModel = DocumentModel().obs;
  final analytics = AnalyticsService.analytics;
  final homeController = Get.find<HomeController>();
  final interstitialAdController = Get.put(InterstitialAdsController());
  late StreamSubscription _intentDataStreamSubscription;

  Future<void> pickFile() async {
    try {
      isLoading.toggle();
      final String? _result = await FlutterFileDialog.pickFile(
          params: const OpenFileDialogParams(
        copyFileToCacheDir: true,
        mimeTypesFilter: ['application/pdf', 'application/octet-stream'],
      ));

      isLoading.toggle();
      confirmDialog(_result);
    } on PlatformException catch (e) {
      isLoading.toggle();
      Get.showSnackbar(GetSnackBar(
        messageText: Text(e.message ?? e.details),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  bool validateRename(String rename) {
    final ext = rename.toLowerCase();
    return ext.endsWith(".pdf");
  }

  void confirmDialog(String? pickedFile) {
    String? _sourceUrl;
    final _result = pickedFile;
    if (_result != null) {
      String _fileName = _result.split('/').last;

      if (!_result.contains('.enc')) {
        Get.bottomSheet(
          WillPopScope(
            onWillPop: () async => false,
            child: Container(
              color: Colors.black,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              child: Wrap(
                children: <Widget>[
                  const Text(
                    'Want to encrypt your file ?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value != null) {
                        if (!validateRename(value)) {
                          return "File Name is not valid";
                        } else {
                          return null;
                        }
                      }
                      return null;
                    },
                    initialValue: _fileName,
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      _fileName = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      helperText:
                          'This file name will be permanently saved to server and cannot be undone',
                      labelText: 'File Name ',
                      helperMaxLines: 3,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.url,
                    onChanged: (value) => _sourceUrl = value,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        helperText:
                            'This Url feature helps users to identify the source of the file  i.e. From where the file was originated.',
                        labelText: 'Source URL / Share Link to redirect',
                        hintText: 'https://t.me/trust_the_professor',
                        helperMaxLines: 3,
                        isDense: true,
                        prefixIcon: Icon(Icons.add_link_rounded),
                        prefixIconColor: Colors.white54),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ButtonBar(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          if (Get.isOverlaysOpen) {
                            Get.back();
                          }
                          if (File(_result).existsSync()) {
                            File(_result).deleteSync();
                          }
                          Get.showSnackbar(
                            const GetSnackBar(
                              message: 'File encryption Canceled',
                              // backgroundColor: Colors.amber,
                              duration: Duration(seconds: 3),
                              snackPosition: SnackPosition.TOP,
                            ),
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (validateRename(_fileName)) {
                            if (Get.isOverlaysOpen) {
                              Get.back();
                            }
                            isLoading.toggle();

                            interstitialAdController.showInterstitialAd();
                            encryptDecrypt(pickedFile,
                                    fileName: _fileName, sourceUrl: _sourceUrl)
                                .then((_fileOut) {
                              if (_fileOut != null) {
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
                              Get.toNamed(Routes.viewPdf, arguments: _fileOut);
                            });
                          }
                        },
                        child: const Text('ENCRYPT'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          isDismissible: false,
        );
      } else {
        encryptDecrypt(pickedFile).then((value) {
          if (value != null) {
            Get.showSnackbar(
              const GetSnackBar(
                messageText: Text('File Saved '),
                duration: Duration(seconds: 3),
                snackPosition: SnackPosition.TOP,
              ),
            );
            final _ownerId =
                GetStorageDbService.getRead(key: value)?['ownerId'];
            interstitialAdController.showInterstitialAd(uid: _ownerId);
            Get.toNamed(Routes.viewPdf, arguments: value);
          } else {
            Get.showSnackbar(
              const GetSnackBar(
                messageText: Text('File Not Saved '),
                duration: Duration(seconds: 3),
                snackPosition: SnackPosition.TOP,
              ),
            );
          }
        });
      }
    }
  }

  Future<String?> encryptDecrypt(String? pickedFile,
      {String? sourceUrl, String? fileName}) async {
    final _result = pickedFile;
    String? _fileOut;
    if (_result != null) {
      try {
        if (_result.contains('.enc')) {
          _fileOut = await doFileCopy(_result);
        } else {
          _fileOut = await doEncryption(_result, sourceUrl, fileName);
        }
      } catch (e) {
        isLoading.value = false;
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
    }
    isLoading.value = false;

    return _fileOut;
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

  Future<String?> doEncryption(
      String _result, String? _sourceUrl, String? fileName) async {
    try {
      String _fileOut = '${await filesDocDir()}/$fileName.enc';
      final secretKey = await FileEncrypter.generatekey();
      final iv = await FileEncrypter.generateiv();
      if (secretKey != null && iv != null) {
        await FileEncrypter.encrypt(
          key: secretKey,
          iv: iv,
          inFilename: _result,
          outFileName: _fileOut,
        );
      }
      final _userId = homeController.user.value.id;
      final _fizeSize = getFileSize(bytes: File(_fileOut).lengthSync());
      final _ownerName = homeController.user.value.name;
      final _ownerPhotoUrl = homeController.user.value.photoUrl;
      final _ownerEmailId = homeController.user.value.emailId;
      final _documentReference =
          await FirestoreData.createDocument(_documentModel(DocumentModel(
        documentName: _fileOut.split('/').last,
        secretKey: secretKey,
        iv: iv,
        ownerId: _userId,
        documentSize: _fizeSize,
        ownerName: _ownerName,
        ownerPhotoUrl: _ownerPhotoUrl,
        ownerEmailId: _ownerEmailId,
        sourceUrl: _sourceUrl,
      )));
      // await FirestoreData.getDocumentsListFromServer(_userId);
      _documentModel(await FirestoreData.getDocument(_documentReference));
      await FirestoreData.createViewsAndUploads(
          _documentModel.value.documentId);
      final Map<String, dynamic> _pdfDetails = {
        'photoUrl': _ownerPhotoUrl,
        'ownerName': _ownerName,
        'sourceUrl': _sourceUrl,
        'ownerId': _userId,
        'intialPageNumber': 0,
      };
      GetStorageDbService.getWrite(key: _fileOut, value: _pdfDetails);
      return _fileOut;
    } on PlatformException {
      isLoading.value = false;

      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 5),
        messageText: Text(e.toString()),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
      ));
      return null;
    }
  }

  Future<String?> doFileCopy(
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
          if (!File(_fileOut).existsSync()) {
            await File(_result).copy(_fileOut);
            await FirestoreData.updateUploads(_document?.documentId);
            final Map<String, dynamic> _pdfDetails = {
              'photoUrl': _document?.ownerPhotoUrl,
              'ownerName': _document?.ownerName,
              'sourceUrl': _document?.sourceUrl,
              'ownerId': _document?.ownerId,
              'intialPageNumber': 0,
            };
            GetStorageDbService.getWrite(key: _fileOut, value: _pdfDetails);
          }
          return _fileOut;
        }
        return null;
        // ! Use of Cloud Function
        // *Using Cloud Firestore temporarily
      }
      return null;
    } on PlatformException catch (e) {
      isLoading.value = false;
      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 5),
        messageText: Text(e.message ?? e.details),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
      ));
      return null;
    }
  }

  String getFileSize({
    required int bytes,
  }) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  void receiveSharing() {
    // await analytics.logEvent(name: 'receive_sharing');
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) async {
      try {
        if (value.isNotEmpty) {
          //   print('Your file name ---------------------------------' +
          //     value.single.path);
          confirmDialog(value.single.path);
        }
      } on PlatformException catch (e) {
        Get.showSnackbar(GetSnackBar(
          messageText: Text(e.message ?? e.details),
          icon: const Icon(Icons.error_outline),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        ));
      }
    }, onError: (err) {
      Get.showSnackbar(GetSnackBar(
        messageText: Text(err.message ?? err.details),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      ));
    });

    // For sharing images coming from outside the app if the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        //  print('Your file name ---------------------------------' +
        //    value.single.path);
        try {
          confirmDialog(value.single.path);
        } on PlatformException catch (e) {
          Get.showSnackbar(GetSnackBar(
            messageText: Text(e.message ?? e.details),
            icon: const Icon(Icons.error_outline),
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          ));
        }
      }
    });
  }

  @override
  void onInit() {
    receiveSharing();
    OpenAsDefault.getFileIntent.then((value) {
      if (value != null) {
        try {
          confirmDialog(value.path);
        } on PlatformException catch (e) {
          Get.showSnackbar(GetSnackBar(
            messageText: Text(e.message ?? e.details),
            icon: const Icon(Icons.error_outline),
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          ));
        }
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    _intentDataStreamSubscription.cancel();
    super.onClose();
  }
}
