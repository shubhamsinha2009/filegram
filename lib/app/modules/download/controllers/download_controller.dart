import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/helpers/ad_helper.dart';
import '../../home/controllers/home_controller.dart';

class DownloadController extends GetxController {
  final chapter = Get.arguments[0] as Reference;
  final bookPath = Get.arguments[1] as String;
  final total = 1.obs;
  final received = 0.obs;
  late http.StreamedResponse response;
  final List<int> _bytes = [];
  final isLoading = true.obs;
  final homeController = Get.find<HomeController>();
  RewardedInterstitialAd? rewardedInterstitialAd;
  // final isRewardedAdReady = false.obs;
  int rewardLoadAttempts = 0;
  final isBottomBannerAdLoaded = false.obs;
  BannerAd? bottomBannerAd;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;
  final getDetails = false.obs;

  Future<void> getdetails(String url) async {
    try {
      response = await http.Client().send(http.Request('GET', Uri.parse(url)));
      total.value = response.contentLength ?? 0;
      received.value = 0;
      getDetails.value = false;
      if (response.statusCode == 400) {
        getDetails.value = true;
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
          title: 'Try Different Source Link',
          message: 'Source Link Now Working at this time',
          duration: const Duration(seconds: 5),
        ));
      }
    } on SocketException catch (_) {
      getDetails.value = true;
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'No Internet Connected',
        message: 'Please Check Internet Connection',
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadFile(String filePath) async {
    final _file = File(filePath);
    try {
      if (response.statusCode == 400) {
        getDetails.value = true;
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
          title: 'Try Different Source Link',
          message: 'Source Link Now Working at this time',
          duration: const Duration(seconds: 5),
        ));
      } else {
        response.stream.listen((value) {
          _bytes.addAll(value);
          received.value += value.length;
        }).onDone(() async {
          if (total.value == received.value) {
            await _file.writeAsBytes(_bytes);
          } else {
            getDetails.value = true;
            received.value = 0;
            Get.showSnackbar(GetSnackBar(
              backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
              title: 'Download Cancelled',
              message: 'Please Check Your Internet Connection',
              duration: const Duration(seconds: 5),
            ));
          }
        });
      }
    } on SocketException catch (_) {
      getDetails.value = true;
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'No Internet Connected',
        message: 'Please Check Internet Connection',
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      getDetails.value = true;
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  // Future<String> filesDocDir() async {
  //   //Get this App Document Directory
  //   //App Document Directory + folder name

  //   final Directory? _appDocDir = await getExternalStorageDirectory();
  //   //App Document Directory + folder name
  //   final Directory _appDocDirFolder =
  //       Directory('${_appDocDir?.path}/Downloads');

  //   if (await _appDocDirFolder.exists()) {
  //     //if folder already exists return path
  //     return _appDocDirFolder.path;
  //   } else {
  //     //if folder not exists create folder and then return its path
  //     final Directory _appDocDirNewFolder =
  //         await _appDocDirFolder.create(recursive: true);
  //     return _appDocDirNewFolder.path;
  //   }
  // }

  void _createBottomBannerAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.downloadBodyBanner,
      size: AdSize.mediumRectangle,
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
    if (isBottomBannerAdLoaded.isFalse) {
      bottomBannerAd?.load();
    }
  }

  Future<void> createInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.viewBookPdf,
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
      getDetails.value = true;
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  Future<void> showInterstitialAd() async {
    try {
      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              adDismissed.value = true;
              createInterstitialAd();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              createInterstitialAd();
            },
            onAdShowedFullScreenContent: (InterstitialAd ad) {});
        if (interstitialAd != null) {
          interstitialAd!.show();
        }
      }
    } on Exception catch (e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
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

  @override
  void onInit() {
    chapter.getDownloadURL().then((value) => getdetails(value));

    // if (kReleaseMode) {
    createInterstitialAd();
    _createBottomBannerAd();
    createRewardedAd();
    // }
    super.onInit();
  }

  @override
  void onClose() {
    // if (kReleaseMode) {
    bottomBannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedInterstitialAd?.dispose();
    // }
  }
}
