import 'dart:async';
import 'dart:io';
import 'package:alh_pdf_view/controller/alh_pdf_view_controller.dart';
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
import '../../no_internet/controllers/no_internet_controller.dart';

class ViewPdfController extends GetxController {
  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;
  final swipehorizontal = false.obs;
  final totalPages = 0.obs;
  final isDecryptionDone = false.obs;
  final isVisible = true.obs;
  late final String filePath;
  final currentPage = 0.obs;
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
  final isInterstitialAdLoaded = false.obs;
  Timer? _timer1;
  // final isBottomBannerAdLoaded = false.obs;
  // late BannerAd bottomBannerAd;
  final countdownTimer = 200.obs;
  bool _shouldAdPlay = Get.arguments[1];
  AlhPdfViewController? pdfViewController;
  static const double _zoomFactor = 0.1;
  List<int> pagesChanged = [];
  int? gotopage;
  int pageTimer = 0;
  final homeController = Get.find<HomeController>();

  Future<bool> doDecryption(String fileIn) async {
    try {
      bool? isEncDone;
      final checkKey = await FileEncrypter.getFileIv(inFilename: fileIn);
      if (checkKey != null) {
        final document = await FirestoreData.getSecretKey(
          checkKey,
          Get.find<HomeController>().user.value.emailId,
          Get.find<HomeController>().user.value.id,
        );
        final secretKey = document?.secretKey;
        if (secretKey != null) {
          isEncDone = await FileEncrypter.decrypt(
            inFilename: fileIn,
            key: secretKey,
            outFileName: fileOut,
          );
        }
        await FirestoreData.updateViews(document?.documentId);
        sourceUrl = document?.sourceUrl;
        ownerId = document?.ownerId;
        ownerName = document?.ownerName;
        photoUrl = document?.ownerPhotoUrl;
      }
      return isEncDone ?? false;
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
            isInterstitialAdLoaded.value = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialLoadAttempts += 1;
            interstitialAd = null;
            isInterstitialAdLoaded.value = false;
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

  // void _createBottomBannerAd() {
  //   bottomBannerAd = BannerAd(
  //     adUnitId: AdHelper.viewPdfBanner,
  //     size: AdSize.banner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isBottomBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   bottomBannerAd.load();
  // }

  // AdWidget adWidget({required AdWithView ad}) {
  //   return AdWidget(ad: ad);
  // }

  void undoPage() {
    if (pdfViewController != null &&
        pagesChanged.first != currentPage.value &&
        pagesChanged.contains(currentPage.value)) {
      pdfViewController!.setPage(
          page: pagesChanged
              .elementAt(pagesChanged.indexOf(currentPage.value) - 1));
    }
  }

  void handleTapPreviousPage() {
    if (pdfViewController != null && currentPage.value != 0) {
      pdfViewController!.setPageWithAnimation(page: currentPage.value - 1);
    }
  }

  void handleTapNextPage() {
    if (pdfViewController != null && currentPage.value != totalPages.value) {
      pdfViewController!.setPageWithAnimation(page: currentPage.value + 1);
    }
  }

  void redoPage() {
    if (pdfViewController != null &&
        pagesChanged.last != currentPage.value &&
        pagesChanged.contains(currentPage.value)) {
      pdfViewController!.setPage(
          page: pagesChanged
              .elementAt(pagesChanged.indexOf(currentPage.value) + 1));
    }
  }

  Future<void> handleTapZoomOut() async {
    if (pdfViewController != null) {
      final currentZoom = await pdfViewController!.getZoom();
      await pdfViewController!.setZoom(zoom: currentZoom - _zoomFactor);
    }
  }

  Future<void> handleTappZoomIn() async {
    if (pdfViewController != null) {
      final currentZoom = await pdfViewController!.getZoom();
      await pdfViewController!.setZoom(zoom: currentZoom + _zoomFactor);
    }
  }

  Future<void> goToPage(int page) async {
    if (pdfViewController != null) {
      await pdfViewController!.setPage(
        page: page,
      );
    }
  }

  @override
  void onInit() async {
    filePath = Get.arguments[0];
    fileOut = filePath.contains('.enc')
        ? '${(await getTemporaryDirectory()).path}/_'
        : filePath;

    try {
      isDecryptionDone.value =
          filePath.contains('.enc') ? await doDecryption(filePath) : true;
    } catch (e) {
      Get.dialog(
        AlertDialog(
          alignment: Alignment.center,
          backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
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

    final Map<String, dynamic>? pdfDetails =
        GetStorageDbService.getRead(key: filePath);
    intialPageNumber = pdfDetails?['intialPageNumber'] ?? 0;

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
        if (pageTimer >= 3) {
          if (pagesChanged.contains(currentPage.value)) {
            pagesChanged.remove(currentPage.value);
          }
          pagesChanged.add(currentPage.value);
          debugPrint(pagesChanged.toString());
          pageTimer = 0;
        }
        pageTimer++;
      },
    );

    try {
      createInterstitialAd();
      //  _createBottomBannerAd();
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
    // bottomBannerAd.dispose();

    if (File(fileOut).existsSync() && filePath.contains('.enc')) {
      await File(fileOut).delete();
    }

    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    final Map<String, dynamic> pdfDetails = {
      'photoUrl': photoUrl,
      'ownerName': ownerName,
      'intialPageNumber': intialPageNumber,
      'ownerId': ownerId,
      'sourceUrl': sourceUrl,
    };
    GetStorageDbService.getWrite(key: filePath, value: pdfDetails);
  }
}
