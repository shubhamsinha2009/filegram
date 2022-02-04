import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdsController extends GetxController {
  final int maxFailedLoadAttempts = 3;
  int rewardLoadAttempts = 0;
  late RewardedAd rewardedAd;
  final isRewardedAdReady = false.obs;

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          rewardedAd = ad;
          rewardLoadAttempts = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              isRewardedAdReady.value = false;

              createRewardedAd();
            },
          );

          isRewardedAdReady.value = true;
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
    rewardedAd.dispose();
    super.onClose();
  }
}
