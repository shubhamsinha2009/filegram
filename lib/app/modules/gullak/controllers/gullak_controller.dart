import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../home/controllers/home_controller.dart';

class GullakController extends GetxController {
  final gullak = Get.find<HomeController>().gullak;

  final int maxFailedLoadAttempts = 3;
  int rewardLoadAttempts = 0;
  late RewardedInterstitialAd rewardedInterstitialAd;
  final isRewardedAdReady = false.obs;
  late BannerAd topBannerAd;
  final istopBannerAdLoaded = false.obs;

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void createRewardedAd() {
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.rewardedAdWithdrawal,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          rewardedInterstitialAd = ad;
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

  void _createBottomBannerAd() {
    topBannerAd = BannerAd(
      adUnitId: AdHelper.gullakBanner,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          istopBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    topBannerAd.load();
  }

  @override
  void onInit() {
    createRewardedAd();
    _createBottomBannerAd();
    super.onInit();
  }

  @override
  void onClose() {
    rewardedInterstitialAd.dispose();
    topBannerAd.dispose();
    super.onClose();
  }
}
