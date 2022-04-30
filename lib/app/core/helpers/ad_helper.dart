import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get viewPdfBanner {
    return dotenv.get('viewPdfBanner');
  }

  static String get viewInterstitial {
    return dotenv.get('viewInterstitial');
  }

  static String get viewPdf {
    return dotenv.get('viewPdf');
  }

  static String get openPdf {
    return dotenv.get('openPdf');
  }

  static String get appOpenAdUnitId {
    return dotenv.get('appOpenAd');
  }

  static String get rewardedAdUnitId {
    return dotenv.get('rewardedAd');
  }
}
