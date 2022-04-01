import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> initServices() async {
  // await AnalyticsService.analytics.logAppOpen();
  // await AnalyticsService.analytics.setDefaultEventParameters({
  //   'version': '1.0.1+1',
  // });

  await MobileAds.instance.initialize();
  loadAd(AdHelper.appOpenAdUnitId);

  await GetStorageDbService.init();
}

void loadAd(String adUnit) {
  AppOpenAd.load(
    adUnitId: adUnit,
    orientation: AppOpenAd.orientationPortrait,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        // print('$ad loaded');
        ad.show();
      },
      onAdFailedToLoad: (error) {
        // print('AppOpenAd failed to load: $error');
      },
    ),
  );
}
