import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:filegram/app/core/extensions.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/helpers/ad_helper.dart';

class FilesDeviceController extends GetxController {
  final rename = ''.obs;
  // late StreamSubscription _intentDataStreamSubscription;
  final filesList = <FileSystemEntity>[].obs;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;
  final inlineAdIndex = 2;
  BannerAd? inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;
  Directory? _mydir;
  final isLoading = true.obs;

  String getSubtitle({required int bytes, required DateTime time}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${DateFormat.yMMMMd('en_US').add_jm().format(time)} - ${'${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}'}';
  }

  bool validateRename() {
    final ext = rename.value.toLowerCase();
    return ext.endsWith(".pdf.enc");
  }

  Future<File> changeFileNameOnlySync(String filePath) async {
    var path = filePath;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + rename.value;

    Hive.box("pdf").put(newPath, Hive.box("pdf").get(filePath));
    Hive.box("pdf").delete(filePath);
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
    _mydir = Directory(await filesDocDir());
    if (_mydir != null) {
      filesList.assignAll(_mydir!.listSync()
        ..sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
        ));
      isLoading.value = false;
    }
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

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void _createInlineBannerAd() {
    inlineBannerAd = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: AdHelper.libraryBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isInlineBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    inlineBannerAd?.load();
  }

  int getListViewItemIndex(int index) {
    if (index >= inlineAdIndex &&
        isInlineBannerAdLoaded.isTrue &&
        (filesList.length >= inlineAdIndex)) {
      return index - 1;
    }
    return index;
  }

  void filterfileList(String fileName) {
    if (_mydir != null) {
      filesList.assignAll(_mydir!
          .listSync()
          .where((FileSystemEntity element) =>
              element.name.toLowerCase().contains(fileName.toLowerCase()))
          .toList()
        ..sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
        ));
    }
  }

  @override
  void onInit() async {
    await onInitialisation();
    _createInlineBannerAd();

    super.onInit();
  }

  @override
  void onClose() {
    interstitialAd?.dispose();
    inlineBannerAd?.dispose();
    super.onClose();
  }
}
