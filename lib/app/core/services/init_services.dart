import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> initServices() async {
  // await AnalyticsService.analytics.logAppOpen();
  // await AnalyticsService.analytics.setDefaultEventParameters({
  //   'version': '1.0.1+1',
  // });
  Future<void> loadAd() async {
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
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

  await MobileAds.instance.initialize();
  await loadAd();
}
