import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../home/controllers/controllers.dart';

class SettingsController extends GetxController {
  final homeController = Get.find<HomeController>();
  final isSettingsBannerAdLoaded = false.obs;
  BannerAd? settingsBannerAd;

  void _createBottomBannerAd() {
    settingsBannerAd = BannerAd(
      adUnitId: AdHelper.settingsBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isSettingsBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    settingsBannerAd?.load();
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void signOut() {
    homeController.auth.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void onInit() {
    _createBottomBannerAd();
    super.onInit();
  }

  @override
  void onClose() {
    settingsBannerAd?.dispose();
    super.onClose();
  }
}
