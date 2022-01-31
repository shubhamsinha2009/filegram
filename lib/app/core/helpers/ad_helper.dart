import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class AdHelper {
  static String get nativeAdUnitId {
    return dotenv.get('homePageAd');
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return MobileAds.interstitialAdTestUnitId;
    } else {
      return 'ca-app-pub-5279463744831556/2065606194';
    }
  }

  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return MobileAds.appOpenAdTestUnitId;
    } else {
      return 'ca-app-pub-5279463744831556/6659457327';
    }
  }

  static String get rewardedInterstitialAdUnitId {
    /// Always test with test ads
    if (kDebugMode) {
      return MobileAds.rewardedInterstitialAdTestUnitId;
    } else {
      return 'ca-app-pub-5279463744831556/1282366936';
    }
  }
}
