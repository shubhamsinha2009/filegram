import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../../core/services/getstorage.dart';
import '../../../data/provider/firestore_data.dart';

class FilesDeviceController extends GetxController {
  final rename = ''.obs;
  // late StreamSubscription _intentDataStreamSubscription;
  final filesList = <FileSystemEntity>[].obs;
  final inlineAdIndex = 0;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;

// final analytics = AnalyticsService.analytics;
  // AppUpdateInfo? _updateInfo;
  //FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> checkForUpdate() async {
  //   // await analytics.logEvent(name: 'app_update_check');
  //   InAppUpdate.checkForUpdate().then((info) {
  //     _updateInfo = info;
  //   }).catchError((e) {
  //     Get.snackbar('Error', e.toString());
  //   });
  // }

  String getSubtitle({required int bytes, required DateTime time}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${DateFormat.yMMMMd('en_US').add_jm().format(time)} - ${((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i]}';
  }

  String nameOfFile(String _currentfilePath) =>
      _currentfilePath.split('/').last;

  bool validateRename() {
    final ext = rename.value.toLowerCase();
    return ext.endsWith(".pdf.enc");
  }

  Future<File> changeFileNameOnlySync(String filePath) async {
    var path = filePath;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + rename.value;

    GetStorageDbService.getWrite(
        key: newPath, value: GetStorageDbService.getRead(key: filePath));
    GetStorageDbService.getRemove(key: filePath);
    return await File(filePath).rename(newPath);
  }

  void save(String path) async {
    final params = SaveFileDialogParams(sourceFilePath: path);
    await FlutterFileDialog.saveFile(params: params);
    // await analytics.logEvent(name: 'file_saved_in_device', parameters: {
    //   'saved_file': _savedFilePath,
    //   'source_file': path,
    // });
  }

  Future<void> onInitialisation() async {
    final _mydir = Directory(await filesDocDir());
    filesList.assignAll(_mydir.listSync()
      ..sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      ));
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

  Future<void> createInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.openPdf,
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
    } on Exception catch (e) {
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
          if (uid != null) {
            FirestoreData.updateSikka(uid);
          }
        });
        interstitialAd!.show();
      }
    } on Exception catch (e) {
      // TODO
    }
  }

  @override
  void onInit() async {
    createInterstitialAd();
    await onInitialisation();

    // await receiveSharing();
    //  await analytics.setCurrentScreen(screenName: 'main_screen');
    // _updateInfo?.updateAvailability == UpdateAvailability.updateAvailable
    //     ? () async {
    //         // await analytics.logEvent(name: 'immediate_app_update');
    //         InAppUpdate.performImmediateUpdate()
    //             .catchError((e) => Get.snackbar('Error', e.toString()));
    //       }
    //     : null;

    super.onInit();
  }

  @override
  void onClose() {
    interstitialAd?.dispose();
    super.onClose();
  }
}
