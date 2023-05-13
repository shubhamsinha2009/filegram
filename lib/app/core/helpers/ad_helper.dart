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

  static String get libraryBanner {
    return dotenv.get('libraryBanner');
  }

  static String get encryptedBanner {
    return dotenv.get('encryptedBanner');
  }

  static String get bottomBanner {
    return dotenv.get('bottomBanner');
  }

  static String get settingsBanner {
    return dotenv.get('settingsBanner');
  }

  static String get viewPdfBanner {
    return dotenv.get('viewPdfBanner');
  }

  static String get rewardedgreencoins {
    return dotenv.get('rewardedgreencoins');
  }
}
