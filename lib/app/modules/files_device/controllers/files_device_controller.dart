import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:filegram/app/controller/interstitial_ads_controller.dart';
import 'package:filegram/app/data/provider/firestore_data.dart';
import 'package:filegram/app/modules/encrypt_decrypt/services/file_encrypter.dart';
import 'package:filegram/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:filegram/app/modules/homebannerad/controllers/homebannerad_controller.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:path_provider/path_provider.dart';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class FilesDeviceController extends GetxController {
  final adsController = Get.find<HomeBannerAdController>();
  final interstitialAdController = Get.put(InterstitialAdsController());
  final rename = ''.obs;
  // late StreamSubscription _intentDataStreamSubscription;
  final filesList = <FileSystemEntity>[].obs;
  final inlineAdIndex = 0;
  late String fileOut;

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

  int getListViewItemIndex(int index) {
    if (index >= inlineAdIndex && adsController.isInlineBannerAdLoaded.value) {
      return index - 1;
    }
    return index;
  }

  String nameOfFile(String _currentfilePath) =>
      _currentfilePath.split('/').last;

  // bool validateRename() {
  //   final ext = rename.value.toLowerCase();
  //   switch (selectedBottomModel.value.bottomType) {
  //     case BottomType.library:
  //       return ext.endsWith(".pdf");
  //     case BottomType.personal:
  //       return ext.endsWith(".sks.pdf");
  //   }
  // }

  Future<File> changeFileNameOnlySync(String filePath) async {
    var path = filePath;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + rename.value;

    return await File(filePath).rename(newPath);
  }

  void save(String path) async {
    final params = SaveFileDialogParams(sourceFilePath: path);
    final _savedFilePath = await FlutterFileDialog.saveFile(params: params);
    // await analytics.logEvent(name: 'file_saved_in_device', parameters: {
    //   'saved_file': _savedFilePath,
    //   'source_file': path,
    // });
  }

  Future<void> onInitialisation() async {
    final _mydir = Directory(await filesDocDir());
    filesList.assignAll(_mydir.listSync());
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
  // Future<void> receiveSharing() async {
  //  // await analytics.logEvent(name: 'receive_sharing');
  //   _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
  //       .listen((List<SharedMediaFile> value) async {
  //     try {
  //       if (value.isNotEmpty) {
  //         //   print('Your file name ---------------------------------' +
  //         //     value.single.path);
  //        // await getOpenitFiles(value.single.path);
  //       }
  //     } catch (e) {
  //       Get.snackbar(
  //         'Error',
  //         'Please Make Sure you are not doing any mistakes by yourself from text update we will find it for you',
  //       );
  //     }
  //   }, onError: (err) {
  //     Get.snackbar(
  //       'Error Found',
  //       err,
  //     );
  //   });

  //   // For sharing images coming from outside the app while the app is closed
  //   ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
  //     if (value.isNotEmpty) {
  //       //  print('Your file name ---------------------------------' +
  //       //    value.single.path);
  //       try {
  //         getOpenitFiles(value.single.path);
  //       } catch (e) {
  //         Get.snackbar(
  //           'Error',
  //           'Please Make Sure you are not doing any mistakes by yourself from text update we will find it for you',
  //         );
  //       }
  //     }
  //   });
  // }

  Future<bool> doDecryption(
    String _fileIn,
  ) async {
    bool? _isEncDone;
    // try {
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
    }
    // } on PlatformException catch (e) {
    //   Get.showSnackbar(GetSnackBar(
    //     duration: const Duration(seconds: 5),
    //     messageText: Text(e.message ?? e.details),
    //     icon: const Icon(Icons.error_outline),
    //     snackPosition: SnackPosition.TOP,
    //   ));
    // }
    return _isEncDone ?? false;
  }

  @override
  void onInit() async {
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
    fileOut = '${(await getTemporaryDirectory()).path}/current.pdf';
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();
  }

  @override
  void onClose() {
    // _intentDataStreamSubscription.cancel();
    super.onClose();
  }
}