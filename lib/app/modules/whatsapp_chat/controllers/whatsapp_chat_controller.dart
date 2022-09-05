import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../home/controllers/home_controller.dart';

class WhatsappChatController extends GetxController {
  String? phoneNumber;
  RewardedInterstitialAd? rewardedInterstitialAd;
  // final isRewardedAdReady = false.obs;
  int rewardLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  final homeController = Get.find<HomeController>();

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
    createRewardedAd();
    super.onInit();
  }

  @override
  void onClose() {
    rewardedInterstitialAd?.dispose();
    // }
    super.onClose();
  }
}
