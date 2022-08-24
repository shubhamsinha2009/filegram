import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_as_default/open_as_default.dart';
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
  late StreamSubscription _intentDataStreamSubscription;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;
  RewardedInterstitialAd? rewardedInterstitialAd;
  int rewardLoadAttempts = 0;

  Future<void> pickFile() async {
    try {
      isLoading.toggle();
      final String? result = await FlutterFileDialog.pickFile(
          params: const OpenFileDialogParams(
        copyFileToCacheDir: true,
        // mimeTypesFilter: [
        //   'application/pdf',
        //   'application/octet-stream',
        // ],
        //TODO : First change mime
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
    return ext.contains(".pdf");
  }

  void confirmDialog(String? pickedFile) {
    String? sourceUrl;
    final result = pickedFile;
    if (result != null) {
      String fileName = result.split('/').last;
      if (result.contains('.pdf')) {
        // Remove Dialog wan
        if (!result.contains('.enc')) {
          Get.bottomSheet(
            // Remove it
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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
                      initialValue: fileName,
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        fileName = value;
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
                          hintText: 'https://t.me/filegram_app',
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
                                      messageText:
                                          const Text('File Not Saved '),
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
              // Get.showSnackbar(
              //   GetSnackBar(
              //     backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
              //     messageText: const Text('File Saved '),
              //     duration: const Duration(seconds: 3),
              //     snackPosition: SnackPosition.TOP,
              //   ),
              // );
              final ownerId =
                  GetStorageDbService.getRead(key: value)?['ownerId'];

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
      } else {
        final String dialogTitle =
            result.contains('.enc') ? 'decrypt' : 'encrypt';
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
              title: Text('Want to $dialogTitle your file ? '),
              content: Text('Your File : $fileName will be ${dialogTitle}ed'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (File(result).existsSync()) {
                      File(result).deleteSync();
                    }
                    Get.back();
                    // Get.showSnackbar(GetSnackBar(
                    //   backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                    //   title: 'File ${dialogTitle}ion Canceled ',
                    //   duration: const Duration(seconds: 3),
                    // ));
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    isLoading.value = true;
                    showInterstitialAd();
                    encryptDecryptSecond(pickedFile);
                    Get.back();
                  },
                  child: Text(dialogTitle.toUpperCase()),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
        // if (!result.contains('.enc')) {
        // } else {

        // }
      }
    }
  }

  Future<void> encryptDecryptSecond(String? pickedFile,
      {String? sourceUrl, String? fileName}) async {
    final _result = pickedFile;
    bool? _isEncDone;

    if (_result != null) {
      String _fileOut = _result.contains('.enc')
          ? _result.replaceAll('.enc', '').trim()
          : '$_result.enc';

      pickedFile = _fileOut;

      try {
        _isEncDone = _result.contains('.enc')
            ? await doDecryption(inFilename: _result, outFileName: _fileOut)
            : await doEncryptionSecond(
                inFilename: _result, outFileName: _fileOut);
      } catch (e) {
        isLoading.value = false;
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
          title: 'Error',
          message: e.toString(),
          duration: const Duration(seconds: 3),
        ));
      } finally {
        if (File(_result).existsSync()) {
          File(_result).deleteSync();
        }
        if (_isEncDone != null && _isEncDone) {
          //   _isSomethingLoading = false;
          if (homeController.gullak.value.sikka >= 5) {
            Get.dialog(AlertDialog(
              alignment: Alignment.center,
              backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
              title: const Text("Don't have enough sikka"),
              content: const Text(
                  'Please watch full rewarded ad to get 5 sikka you need to save your file'),
              actions: [
                OutlinedButton(
                    onPressed: () {
                      Get.back();
                      isLoading.value = false;
                    },
                    child: const Text('Back')),
                OutlinedButton(
                    onPressed: () {
                      Get.back();
                      if (homeController.user.value.id != null) {
                        FirestoreData.updateSikka(
                            uid: homeController.user.value.id!, increment: -4);
                        saveFile(pickedFile);
                      }
                    },
                    child: const Text('Spend 3 Sikka')),
                OutlinedButton(
                    onPressed: () {
                      Get.back();
                      if (rewardedInterstitialAd != null) {
                        rewardedInterstitialAd?.show(
                            onUserEarnedReward: (ad, reward) async {
                          if (homeController.user.value.id != null) {
                            // FirestoreData.updateSikka(
                            //     uid: homeController.user.value.id!,
                            //     increment: reward.amount);
                            saveFile(pickedFile);
                          }
                        });
                      } else {
                        saveFile(pickedFile);
                      }
                    },
                    child: const Text('Watch Rewarded Ad'))
              ],
            ));
          } else {
            Get.dialog(AlertDialog(
              alignment: Alignment.center,
              backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
              title: const Text("Don't have enough sikka"),
              content: const Text(
                  'Please watch full rewarded ad to get 5 sikka you need to save your file'),
              actions: [
                OutlinedButton(
                    onPressed: () {
                      Get.back();
                      isLoading.value = false;
                    },
                    child: const Text('Back')),
                OutlinedButton(
                    onPressed: () {
                      Get.back();
                      if (rewardedInterstitialAd != null) {
                        rewardedInterstitialAd?.show(
                            onUserEarnedReward: (ad, reward) async {
                          if (homeController.user.value.id != null) {
                            // FirestoreData.updateSikka(
                            //     uid: homeController.user.value.id!,
                            //     increment: reward.amount);
                            saveFile(pickedFile);
                          }
                        });
                      } else {
                        saveFile(pickedFile);
                      }
                    },
                    child: const Text('Watch Rewarded Ad'))
              ],
            ));
          }
        }
      }
    }
  }

  Future<void> saveFile(String? pickedFile) async {
    if (pickedFile != null) {
      String? _fileSavedPath;
      final String _fileOut = pickedFile;
      try {
        final params = SaveFileDialogParams(sourceFilePath: _fileOut);
        _fileSavedPath = await FlutterFileDialog.saveFile(params: params);
      } catch (e) {
        isLoading.value = false;
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
          title: 'Error',
          message: e.toString(),
          duration: const Duration(seconds: 5),
        ));
      } finally {
        isLoading.value = false;

        if (File(_fileOut).existsSync()) {
          File(_fileOut).deleteSync();
        }
        if (File('$_fileOut.enc').existsSync()) {
          File('$_fileOut.enc').deleteSync();
        }
        if (File(_fileOut.replaceAll('.enc', '').trim()).existsSync()) {
          File(_fileOut.replaceAll('.enc', '').trim()).deleteSync();
        }
        if (_fileSavedPath != null) {
          Get.showSnackbar(GetSnackBar(
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
            message: 'File Saved',
            duration: const Duration(seconds: 3),
          ));
        } else {
          Get.showSnackbar(GetSnackBar(
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
            title: 'File Not Saved',
            duration: const Duration(seconds: 3),
          ));
        }
      }
    }
  }

  void createRewardedAd() {
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.downloadReward,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          rewardedInterstitialAd = ad;
          rewardLoadAttempts = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // isRewardedAdReady.value = false;

              createRewardedAd();
            },
          );

          // isRewardedAdReady.value = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          // print('Failed to load a rewarded ad: ${err.message}');
          rewardLoadAttempts += 1;
          if (rewardLoadAttempts <= maxFailedLoadAttempts) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  Future<bool?> doDecryption(
      {required String inFilename, required String outFileName}) async {
    try {
      bool? isEncDone;
      final checkKey = await FileEncrypter.getFileIv(inFilename: inFilename);
      if (checkKey != null) {
        final document = await FirestoreData.getSecretKey(
          collection: 'otherfiles',
          iv: checkKey,
          userEmail: Get.find<HomeController>().user.value.emailId,
          ownerId: Get.find<HomeController>().user.value.id,
        );
        final secretKey = document?.secretKey;
        if (secretKey != null) {
          isEncDone = await FileEncrypter.decrypt(
            inFilename: inFilename,
            key: secretKey,
            outFileName: outFileName,
          );
        }
        await FirestoreData.updateViews(
            collection: 'otherviews', documentID: document?.documentId);
        FirestoreData.updateSikka(uid: document!.ownerId!, increment: 1);
      }
      return isEncDone;
    } catch (e) {
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

  Future<String?> encryptDecrypt(String? pickedFile,
      {String? sourceUrl, String? fileName}) async {
    final result = pickedFile;
    String? fileOut;
    if (result != null) {
      try {
        if (result.contains('.enc')) {
          // TODO: Second Step - Divide two collection
          //TODO: third step - decryption function
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

  Future<bool?> doEncryptionSecond(
      {required String inFilename, required String outFileName}) async {
    try {
      bool? isEncDone;
      final secretKey = await FileEncrypter.generatekey();
      final iv = await FileEncrypter.generateiv();
      if (secretKey != null && iv != null) {
        isEncDone = await FileEncrypter.encrypt(
          key: secretKey,
          iv: iv,
          inFilename: inFilename,
          outFileName: outFileName,
        );
      }
      final userId = homeController.user.value.id;
      final fizeSize = getFileSize(bytes: File(outFileName).lengthSync());
      final ownerName = homeController.user.value.name;
      final ownerPhotoUrl = homeController.user.value.photoUrl;
      final ownerEmailId = homeController.user.value.emailId;
      final documentReference = await FirestoreData.createDocument(
          documentModel: _documentModel(DocumentModel(
            documentName: outFileName.split('/').last,
            secretKey: secretKey,
            iv: iv,
            ownerId: userId,
            documentSize: fizeSize,
            ownerName: ownerName,
            ownerPhotoUrl: ownerPhotoUrl,
            ownerEmailId: ownerEmailId,
          )),
          collection: 'otherfiles');
      // await FirestoreData.getDocumentsListFromServer(_userId);
      _documentModel(await FirestoreData.getDocument(documentReference));
      await FirestoreData.createViewsAndUploads(
          collection: 'otherviews',
          documentId: _documentModel.value.documentId);
      return isEncDone;
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
      final documentReference = await FirestoreData.createDocument(
          documentModel: _documentModel(DocumentModel(
            documentName: fileOut.split('/').last,
            secretKey: secretKey,
            iv: iv,
            ownerId: userId,
            documentSize: fizeSize,
            ownerName: ownerName,
            ownerPhotoUrl: ownerPhotoUrl,
            ownerEmailId: ownerEmailId,
            sourceUrl: sourceUrl,
          )),
          collection: "files");
      // await FirestoreData.getDocumentsListFromServer(_userId);
      _documentModel(await FirestoreData.getDocument(documentReference));
      await FirestoreData.createViewsAndUploads(
          collection: "views", documentId: _documentModel.value.documentId);
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
          collection: 'files',
          iv: checkKey,
          userEmail: homeController.user.value.emailId,
          ownerId: homeController.user.value.id,
        );
        final secretKey = document?.secretKey;
        if (secretKey != null) {
          String fileOut = '${await filesDocDir()}/${document?.documentName}';
          if (!File(fileOut).existsSync()) {
            await File(result).copy(fileOut);
            await FirestoreData.updateUploads(
                collection: 'views', documentID: document?.documentId);
            final Map<String, dynamic> pdfDetails = {
              'photoUrl': document?.ownerPhotoUrl,
              'ownerName': document?.ownerName,
              'sourceUrl': document?.sourceUrl,
              'ownerId': document?.ownerId,
              'intialPageNumber': 0,
            };
            GetStorageDbService.getWrite(key: fileOut, value: pdfDetails);
            Get.showSnackbar(
              GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('File Saved '),
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.TOP,
              ),
            );
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
    }).onError((error, stackTrace) => null);
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
            FirestoreData.updateSikka(uid: uid, increment: 1);
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
    createRewardedAd();
    createInterstitialAd().catchError((e) {});
    receiveSharing();
    OpenAsDefault.getFileIntent.then((value) {
      // TODO : Remove error coming on firebase
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
    }).catchError((e) {});

    super.onInit();
  }

  @override
  void onClose() {
    interstitialAd?.dispose();
    rewardedInterstitialAd?.dispose();
    _intentDataStreamSubscription.cancel();
    super.onClose();
  }
}
