import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/helpers/ad_helper.dart';

class CoinsController extends GetxController {
  final coins = (Hive.box('user').get('coins', defaultValue: 5) as int).obs;
  RewardedAd? _rewardedAd;

  void showRewardedAd() {
    if (coins.value < 40) {
      if (_rewardedAd != null) {
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _createRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _createRewardedAd();
          },
        );
        _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            coins.value = coins.value + reward.amount as int;
            Hive.box('user').put('coins', coins.value);
          },
        );
        _rewardedAd = null;
      } else {
        if (coins.value < 5) {
          coins.value = coins.value + 5;
          Hive.box('user').put('coins', coins.value);
        }
      }
    }
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedgreencoins,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
        _rewardedAd = ad;
      }, onAdFailedToLoad: (error) {
        _rewardedAd = null;
      }),
    );
  }

  @override
  void onInit() {
    _createRewardedAd();
    super.onInit();
  }
}
