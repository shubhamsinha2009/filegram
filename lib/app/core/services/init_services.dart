import 'package:filegram/app/core/services/getstorage.dart';

Future<void> initServices() async {
  // await AnalyticsService.analytics.logAppOpen();
  // await AnalyticsService.analytics.setDefaultEventParameters({
  //   'version': '1.0.1+1',
  // });

  await GetStorageDbService.init();
}
