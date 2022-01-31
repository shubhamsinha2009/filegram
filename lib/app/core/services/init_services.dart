import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'firebase_analytics.dart';

Future<void> initServices() async {
  await AnalyticsService.analytics.logAppOpen();
  await AnalyticsService.analytics.setDefaultEventParameters({
    'version': '1.0.1+1',
  });

  await MobileAds.initialize(
    nativeAdUnitId: AdHelper.nativeAdUnitId,
    // interstitialAdUnitId: AdHelper.interstitialAdUnitId,
    // appOpenAdUnitId: AdHelper.appOpenAdUnitId,
    // rewardedInterstitialAdUnitId: AdHelper.rewardedInterstitialAdUnitId,
  );
}
