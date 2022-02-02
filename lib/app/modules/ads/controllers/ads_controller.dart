import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends GetxController {
  late BannerAd inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  int rewardLoadAttempts = 0;
  late RewardedAd rewardedAd;
  final isRewardedAdReady = false.obs;

  @override
  void onInit() {
    createInlineBannerAd();
    createInterstitialAd();
    createRewardedAd();
    super.onInit();
  }

  @override
  void onClose() {
    inlineBannerAd.dispose();
    interstitialAd?.dispose();
    rewardedAd.dispose();
    super.onClose();
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void createInlineBannerAd() {
    inlineBannerAd = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: AdHelper.bannerAdUnitId,
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
    inlineBannerAd.load();
  }

  //  void createMenuBannerAd() {
  //   menuBannerAd = BannerAd(
  //     size: AdSize.mediumRectangle,
  //     adUnitId: AdHelper.bannerAdUnitId,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isMenuBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   menuBannerAd.load();
  // }

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
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
  }

  Future<void> showInterstitialAd() async {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          createInterstitialAd();
        },
      );
      interstitialAd!.show();
    }
  }

  // void showRewardAd(Future<void> rewardEarned) {
  //   // rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
  //   //   onAdDismissedFullScreenContent: (RewardedAd ad) {
  //   //     ad.dispose();
  //   //     createRewardedAd();
  //   //   },
  //   //   onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
  //   //     ad.dispose();
  //   //     createRewardedAd();
  //   //   },
  //   // );
  //   rewardedAd.show(
  //     onUserEarnedReward: (ad, reward) async {

  //       // await rewardEarned;
  //     },
  //   );
  // }

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
}
