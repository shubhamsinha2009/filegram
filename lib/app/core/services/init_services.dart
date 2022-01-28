import 'firebase_analytics.dart';

Future<void> initServices() async {
  await AnalyticsService.analytics.logAppOpen();
  await AnalyticsService.analytics.setDefaultEventParameters({
    'version': '1.0.1+1',
  });
}
