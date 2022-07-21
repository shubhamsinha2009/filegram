import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class DashboardController extends GetxController {
  // final isBottomBannerAdLoaded = false.obs;
  // late BannerAd bottomBannerAd;
  var classList = <Reference>[];
  final filterclassList = <Reference>[].obs;
  final homeController = Get.find<HomeController>();

  void filterfileList(String fileName) {
    if (fileName.isEmpty) {
      filterclassList.assignAll(classList);
    } else {
      filterclassList.assignAll(classList
          .where((classes) =>
              classes.name.toLowerCase().contains(fileName.toLowerCase()))
          .toList());
    }
  }

  // void _createBottomBannerAd() {
  //   bottomBannerAd = BannerAd(
  //     adUnitId: AdHelper.dashboardBanner,
  //     size: AdSize.largeBanner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isBottomBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   if (isBottomBannerAdLoaded.isFalse) {
  //     bottomBannerAd.load();
  //   }
  // }

  // AdWidget adWidget({required AdWithView ad}) {
  //   return AdWidget(ad: ad);
  // }
  void firebaseStorage() {
    FirebaseStorage.instance
        .ref()
        .child("classes")
        .listAll()
        .then((ListResult value) {
      classList = value.prefixes;
      filterclassList.assignAll(classList);
      // debugPrint(classList.toString());
    });
  }

  @override
  void onInit() {
    firebaseStorage();

    // if (kReleaseMode) {
    //   _createBottomBannerAd();
    // }
    super.onInit();
  }
}
