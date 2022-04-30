import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get gullakBanner {
    return dotenv.get('gullakBanner');
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

  static String get rewardedAdWithdrawal {
    return dotenv.get('rewardedAdWithdrawal');
  }

  static String get libraryBanner {
    return dotenv.get('libraryBanner');
  }

  static String get encryptedBanner {
    return dotenv.get('encryptedBanner');
  }
}
