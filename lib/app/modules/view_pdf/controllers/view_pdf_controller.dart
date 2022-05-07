import 'dart:async';
import 'dart:io';

import 'package:filegram/app/core/services/getstorage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';

import '../../../core/helpers/ad_helper.dart';
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
  int intialPageNumber = 0;
  String? photoUrl;
  String? ownerName;
  late File file;
  late String fileOut;
  String? sourceUrl;
  String? ownerId;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;
  Timer? _timer1;
  final isBottomBannerAdLoaded = false.obs;
  late BannerAd bottomBannerAd;
  final countdownTimer = 200.obs;
  bool _shouldAdPlay = Get.arguments[1];

  Future<bool> doDecryption(String _fileIn) async {
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
        ownerId = _document?.ownerId;
        ownerName = _document?.ownerName;
        photoUrl = _document?.ownerPhotoUrl;
      }
      return _isEncDone ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.viewPdf,
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
          if ((uid != null) &&
              (Get.find<HomeController>().user.value.id != uid)) {
            FirestoreData.updateSikka(uid);
          }
        });
        interstitialAd!.show();
      }
    } on Exception {
      // TODO
    }
  }

  void _createBottomBannerAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.viewPdfBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBottomBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    bottomBannerAd.load();
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  @override
  void onInit() async {
    filePath = Get.arguments[0];
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
    intialPageNumber = _pdfDetails?['intialPageNumber'];

    _timer1 = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (countdownTimer.value == 0) {
          showInterstitialAd(uid: ownerId)
              .then((value) => countdownTimer.value = 200)
              .catchError((e) {});
        } else {
          countdownTimer.value--;
        }
        if (_shouldAdPlay && countdownTimer.value == 10) {
          _shouldAdPlay = false;
          showInterstitialAd(uid: ownerId).catchError((e) {});
        }
      },
    );

    try {
      createInterstitialAd();
      _createBottomBannerAd();
    } on Exception catch (e) {
      // TODO
    }
    Wakelock.toggle(enable: true);
    super.onInit();
  }

  @override
  void onReady() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

    super.onReady();
  }

  @override
  void onClose() async {
    _timer1?.cancel();
    interstitialAd?.dispose();
    bottomBannerAd.dispose();

    if (File(fileOut).existsSync()) {
      await File(fileOut).delete();
    }

    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    final Map<String, dynamic> _pdfDetails = {
      'photoUrl': photoUrl,
      'ownerName': ownerName,
      'intialPageNumber': intialPageNumber,
      'ownerId': ownerId,
      'sourceUrl': sourceUrl,
    };
    GetStorageDbService.getWrite(key: filePath, value: _pdfDetails);
  }
}
