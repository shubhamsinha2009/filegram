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

  static String get bookBanner {
    return dotenv.get('bookBanner');
  }

  static String get viewBookPdf {
    return dotenv.get('viewBookPdf');
  }

  static String get bookBottom {
    return dotenv.get('bookBottom');
  }

  static String get downloadReward {
    return dotenv.get('downloadReward');
  }

  static String get downloadBodyBanner {
    return dotenv.get('downloadBodyBanner');
  }

  static String get downoadInlineBanner {
    return dotenv.get('downoadInlineBanner');
  }

  static String get downoadBottomBanner {
    return dotenv.get('downoadBottomBanner');
  }

  static String get subjectbottomBanner {
    return dotenv.get('subjectbottomBanner');
  }

  static String get subjectBodyBanner {
    return dotenv.get('subjectBodyBanner');
  }

  static String get dashboardBanner {
    return dotenv.get('dashboardBanner');
  }

  static String get booksBottomBanner {
    return dotenv.get('booksBottomBanner');
  }

  static String get booksBodyBanner {
    return dotenv.get('booksBodyBanner');
  }
}
