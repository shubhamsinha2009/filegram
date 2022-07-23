import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../home/controllers/home_controller.dart';

class SubjectController extends GetxController {
  final isBottomBannerAdLoaded = false.obs;
  BannerAd? bottomBannerAd;
  final isBodyBannerAdLoaded = false.obs;
  BannerAd? bodyBannerAd;
  var subjectList = <Reference>[];
  final filteredsubjectList = <Reference>[].obs;
  final homeController = Get.find<HomeController>();
  final classes = Get.arguments as Reference;
  final isLoading = true.obs;

  void filterfileList(String fileName) {
    if (fileName.isEmpty) {
      filteredsubjectList.assignAll(subjectList);
    } else {
      filteredsubjectList.assignAll(subjectList
          .where((subject) =>
              subject.name.toLowerCase().contains(fileName.toLowerCase()))
          .toList());
    }
  }

  void _createBottomBannerAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.subjectbottomBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBottomBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    if (isBottomBannerAdLoaded.isFalse) {
      bottomBannerAd?.load();
    }
  }

  void _createBodyBannerAd() {
    bodyBannerAd = BannerAd(
      adUnitId: AdHelper.subjectBodyBanner,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBodyBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    if (isBodyBannerAdLoaded.isFalse) {
      bodyBannerAd?.load();
    }
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void firebaseStorage() {
    FirebaseStorage.instance
        .ref()
        .child(classes.fullPath)
        .listAll()
        .then((ListResult value) {
      subjectList = value.prefixes;
      filteredsubjectList.assignAll(subjectList);
      //debugPrint(classList.toString());
    }).whenComplete(() => isLoading.value = false);
  }

  @override
  void onInit() {
    firebaseStorage();
    // subjectList.assignAll(classes.subjectList);
    // if (kReleaseMode) {
    _createBottomBannerAd();
    _createBodyBannerAd();
    // }
    super.onInit();
  }

  @override
  void onClose() {
    bodyBannerAd?.dispose();
    bottomBannerAd?.dispose();
    super.onClose();
  }
}
