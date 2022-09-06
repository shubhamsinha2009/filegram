import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_as_default_adv/open_as_default_adv.dart';
import 'package:filegram/app/core/extensions.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/helpers/ad_helper.dart';
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
  StreamSubscription? _intentDataStreamSubscription;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;

  Future<void> pickFile() async {
    try {
      isLoading.toggle();
      final String? result = await FlutterFileDialog.pickFile(
          params: const OpenFileDialogParams(
        copyFileToCacheDir: true,
        mimeTypesFilter: ['application/pdf', 'application/octet-stream'],
      ));

      isLoading.toggle();
      confirmDialog(result);
    } on PlatformException catch (e) {
      isLoading.toggle();
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
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
    String? sourceUrl;
    final result = pickedFile;
    if (result != null) {
      String fileName = result.split('/').last;

      if (!result.contains('.enc')) {
        Get.bottomSheet(
          WillPopScope(
            onWillPop: () async => false,
            child: Container(
              color: Get.isDarkMode ? Colors.black : Colors.white,
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
                        if (!validateRename('$value.pdf')) {
                          return "File Name is not valid";
                        } else {
                          return null;
                        }
                      }
                      return null;
                    },
                    initialValue: fileName.removeExtension,
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      fileName = '$value.pdf';
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
                    onChanged: (value) => sourceUrl = value,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        helperText:
                            'This Url feature helps users to identify the source of the file  i.e. From where the file was originated.',
                        labelText: 'Source URL / Share Link to redirect',
                        hintText: 'https://t.me/filegram',
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
                          if (File(result).existsSync()) {
                            File(result).deleteSync();
                          }
                          Get.showSnackbar(
                            GetSnackBar(
                              backgroundColor:
                                  Get.theme.snackBarTheme.backgroundColor!,
                              message: 'File encryption Canceled',

                              // backgroundColor: Colors.amber,
                              duration: const Duration(seconds: 3),
                              snackPosition: SnackPosition.TOP,
                            ),
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (validateRename(fileName)) {
                            if (Get.isOverlaysOpen) {
                              Get.back();
                            }
                            isLoading.toggle();
                            showInterstitialAd().catchError((e) {});
                            encryptDecrypt(pickedFile,
                                    fileName: fileName, sourceUrl: sourceUrl)
                                .then((fileOut) {
                              if (fileOut != null) {
                                Get.showSnackbar(
                                  GetSnackBar(
                                    backgroundColor: Get
                                        .theme.snackBarTheme.backgroundColor!,
                                    messageText: const Text('File Saved '),
                                    duration: const Duration(seconds: 3),
                                    snackPosition: SnackPosition.TOP,
                                  ),
                                );
                              } else {
                                Get.showSnackbar(
                                  GetSnackBar(
                                    backgroundColor: Get
                                        .theme.snackBarTheme.backgroundColor!,
                                    messageText: const Text('File Not Saved '),
                                    duration: const Duration(seconds: 3),
                                    snackPosition: SnackPosition.TOP,
                                  ),
                                );
                              }
                              Get.toNamed(Routes.viewPdf,
                                  arguments: [fileOut, true]);
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
              GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('File Saved '),
                duration: const Duration(seconds: 3),
                snackPosition: SnackPosition.TOP,
              ),
            );
            final ownerId = GetStorageDbService.getRead(key: value)?['ownerId'];

            // rewardedAdController.rewardedInterstitialAd.show(
            //     onUserEarnedReward: (ad, reward) {
            //   FirestoreData.updateSikka(_ownerId);

            showInterstitialAd(uid: ownerId).catchError((e) {});
            Get.toNamed(Routes.viewPdf, arguments: [value, true]);
            // });

          } else {
            Get.showSnackbar(
              GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('File Not Saved '),
                duration: const Duration(seconds: 3),
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
    final result = pickedFile;
    String? fileOut;
    if (result != null) {
      try {
        if (result.contains('.enc')) {
          fileOut = await doFileCopy(result);
        } else {
          fileOut = await doEncryption(result, sourceUrl, fileName);
        }
      } catch (e) {
        isLoading.value = false;
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
          messageText: Text(e.toString()),
          icon: const Icon(Icons.error_outline),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        ));
      }
      if (File(result).existsSync()) {
        File(result).deleteSync();
      }
    }
    isLoading.value = false;

    return fileOut;
  }

  Future<String> filesDocDir() async {
    //Get this App Document Directory
    //App Document Directory + folder name

    final Directory? appDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory appDocDirFolder = Directory('${appDocDir?.path}/Files');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  Future<String?> doEncryption(
      String result, String? sourceUrl, String? fileName) async {
    try {
      String fileOut = '${await filesDocDir()}/$fileName.enc';
      final secretKey = await FileEncrypter.generatekey();
      final iv = await FileEncrypter.generateiv();
      if (secretKey != null && iv != null) {
        await FileEncrypter.encrypt(
          key: secretKey,
          iv: iv,
          inFilename: result,
          outFileName: fileOut,
        );
      }
      final userId = homeController.user.value.id;
      final fizeSize = getFileSize(bytes: File(fileOut).lengthSync());
      final ownerName = homeController.user.value.name;
      final ownerPhotoUrl = homeController.user.value.photoUrl;
      final ownerEmailId = homeController.user.value.emailId;
      final documentReference =
          await FirestoreData.createDocument(_documentModel(DocumentModel(
        documentName: fileOut.split('/').last,
        secretKey: secretKey,
        iv: iv,
        ownerId: userId,
        documentSize: fizeSize,
        ownerName: ownerName,
        ownerPhotoUrl: ownerPhotoUrl,
        ownerEmailId: ownerEmailId,
        sourceUrl: sourceUrl,
      )));
      // await FirestoreData.getDocumentsListFromServer(_userId);
      _documentModel(await FirestoreData.getDocument(documentReference));
      await FirestoreData.createViewsAndUploads(
          _documentModel.value.documentId);
      final Map<String, dynamic> pdfDetails = {
        'photoUrl': ownerPhotoUrl,
        'ownerName': ownerName,
        'sourceUrl': sourceUrl,
        'ownerId': userId,
        'intialPageNumber': 0,
      };
      GetStorageDbService.getWrite(key: fileOut, value: pdfDetails);
      return fileOut;
    } on PlatformException {
      isLoading.value = false;

      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        duration: const Duration(seconds: 5),
        messageText: Text(e.toString()),
        icon: const Icon(Icons.error_outline),
        snackPosition: SnackPosition.TOP,
      ));
      return null;
    }
  }

  Future<String?> doFileCopy(
    String result,
  ) async {
    try {
      // _fileOut = '${await filesDocDir()}/$_filename';
      final checkKey = await FileEncrypter.getFileIv(inFilename: result);
      if (checkKey != null) {
        final document = await FirestoreData.getSecretKey(
          checkKey,
          homeController.user.value.emailId,
          homeController.user.value.id,
        );
        final secretKey = document?.secretKey;
        if (secretKey != null) {
          String fileOut = '${await filesDocDir()}/${document?.documentName}';
          if (!File(fileOut).existsSync()) {
            await File(result).copy(fileOut);
            await FirestoreData.updateUploads(document?.documentId);
            final Map<String, dynamic> pdfDetails = {
              'photoUrl': document?.ownerPhotoUrl,
              'ownerName': document?.ownerName,
              'sourceUrl': document?.sourceUrl,
              'ownerId': document?.ownerId,
              'intialPageNumber': 0,
            };
            GetStorageDbService.getWrite(key: fileOut, value: pdfDetails);
          }
          return fileOut;
        }
        return null;
        // ! Use of Cloud Function
        // *Using Cloud Firestore temporarily
      }
      return null;
    } on PlatformException catch (e) {
      isLoading.value = false;
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
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
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
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
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
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
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
            messageText: Text(e.message ?? e.details),
            icon: const Icon(Icons.error_outline),
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          ));
        }
      }
    });
  }

  Future<void> createInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.viewInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
            interstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialLoadAttempts += 1;
            interstitialAd = null;
            if (interstitialLoadAttempts <= maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ),
      );
    } on Exception {
      // TODO
    }
  }

// AdWidget adWidget({required AdWithView ad}) {
//     return AdWidget(ad: ad);
//   }
  Future<void> showInterstitialAd({String? uid}) async {
    try {
      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          adDismissed.value = true;
          createInterstitialAd();
        }, onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
          ad.dispose();
          createInterstitialAd();
        }, onAdShowedFullScreenContent: (InterstitialAd ad) {
          if ((uid != null) && (homeController.user.value.id != uid)) {
            FirestoreData.updateSikka(uid);
          }
        });
        interstitialAd!.show();
      }
    } on Exception {
      // TODO
    }
  }

  @override
  void onInit() {
    createInterstitialAd().catchError((e) {});
    receiveSharing();
    OpenAsDefault.getFileIntent.then((value) {
      if (value != null) {
        try {
          confirmDialog(value.path);
        } on PlatformException catch (e) {
          Get.showSnackbar(GetSnackBar(
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
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
    interstitialAd?.dispose();
    _intentDataStreamSubscription?.cancel();
    super.onClose();
  }
}
