import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeBannerAdController extends GetxController {
  late BannerAd inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;
  final isInlineAdMounted = false.obs;

  @override
  void onInit() {
    createInlineBannerAd();
    super.onInit();
  }

  @override
  void onClose() {
    inlineBannerAd.dispose();
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

  // void showRewardAd(Future<void> rewardEarned) {
  // rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
  //   onAdDismissedFullScreenContent: (RewardedAd ad) {
  //     ad.dispose();
  //     createRewardedAd();
  //   },
  //   onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
  //     ad.dispose();
  //     createRewardedAd();
  //   },
  // );
  //   rewardedAd.show(
  //     onUserEarnedReward: (ad, reward) async {

  //       // await rewardEarned;
  //     },
  //   );
  // }

  // void loadAd() {
  //   AppOpenAd.load(
  //     adUnitId: AdHelper.appOpenAdUnitId,
  //     orientation: AppOpenAd.orientationPortrait,
  //     request: const AdRequest(),
  //     adLoadCallback: AppOpenAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         // print('$ad loaded');

  //         appOpenAd = ad;
  //       },
  //       onAdFailedToLoad: (error) {
  //         // print('AppOpenAd failed to load: $error');
  //       },
  //     ),
  //   );
  // }

  // /// Shows the ad, if one exists and is not already being shown.
  // ///
  // /// If the previously cached ad has expired, this just loads and caches a
  // /// new ad.
  // void showAdIfAvailable() {
  //   if (appOpenAd == null) {
  //     //print('Tried to show ad before available.');
  //     loadAd();
  //   }
  //   if (isShowingAd.value) {
  //     // print('Tried to show ad while already showing an ad.');
  //     return;
  //   }

  //   // Set the fullScreenContentCallback and show the ad.
  //   appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       isShowingAd.value = true;
  //       // print('$ad onAdShowedFullScreenContent');
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       //print('$ad onAdFailedToShowFullScreenContent: $error');
  //       isShowingAd.value = false;
  //       ad.dispose();
  //       appOpenAd = null;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       // print('$ad onAdDismissedFullScreenContent');
  //       isShowingAd.value = false;
  //       ad.dispose();
  //       appOpenAd = null;
  //       loadAd();
  //     },
  //   );
  //   appOpenAd!.show();
  // }

}
