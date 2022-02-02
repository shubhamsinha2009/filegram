import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get bannerAdUnitId {
    return dotenv.get('homePageAd');
  }

  static String get interstitialAdUnitId {
    return dotenv.get('viewInterstitial');
  }

  static String get appOpenAdUnitId {
    return dotenv.get('appOpenAd');
  }

  static String get rewardedAdUnitId {
    return dotenv.get('rewardedAd');
  }
}
