import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_analytics.dart';

Future<void> initServices() async {
  await AnalyticsService.analytics.logAppOpen();
  await AnalyticsService.analytics.setDefaultEventParameters({
    'version': '1.0.1+1',
  });
  await MobileAds.instance.initialize();
}
