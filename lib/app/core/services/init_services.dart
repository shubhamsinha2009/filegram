import 'firebase_analytics.dart';

Future<void> initServices() async {
  final _analytics = AnalyticsService.analytics;
  await _analytics.logAppOpen();
  await _analytics.setDefaultEventParameters({
    'version': '1.0.1+1',
  });
}
