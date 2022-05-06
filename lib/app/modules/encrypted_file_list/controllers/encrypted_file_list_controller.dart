import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../../data/enums/docpermission.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/model/documents_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';
import 'package:get/get.dart';

class EncryptedFileListController extends GetxController
    with StateMixin<List<DocumentModel>>, ScrollMixin {
  List<DocumentModel> documents = [];
  final int documentPerPage = 5;
  bool getFirstData = false;
  int page = 1;
  bool lastPage = false;
  final homeController = Get.find<HomeController>();
  final sharedEmailIds = <String>[].obs;
  String? sourceUrl;
  final TextEditingController textEditingController = TextEditingController();
  final groupValue = DocumentPermission.public.obs;
  final inlineAdIndex = 1;
  late BannerAd inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;
  // late BannerAd topBannerAd;
  // final istopBannerAdLoaded = false.obs;
  // final int maxFailedLoadAttempts = 3;
  // int rewardLoadAttempts = 0;
  // late BannerAd viewsBannerAd;
  // final isViewsBannerAdLoaded = false.obs;
  // late BannerAd linkBannerAd;
  // final isLinkBannerAdLoaded = false.obs;
  // late RewardedInterstitialAd rewardedInterstitialAd;
  // final isRewardedAdReady = false.obs;

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  // void _createBottomBannerAd() {
  //   topBannerAd = BannerAd(
  //     adUnitId: AdHelper.docBanner,
  //     size: AdSize.mediumRectangle,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         istopBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );

  //   topBannerAd.load();
  // }

  // void _createViewsBannerAd() {
  //   topBannerAd = BannerAd(
  //     adUnitId: AdHelper.viewsBanner,
  //     size: AdSize.mediumRectangle,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isViewsBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );

  //   viewsBannerAd.load();
  // }

  // void _createLinkBannerAd() {
  //   topBannerAd = BannerAd(
  //     adUnitId: AdHelper.linkBanner,
  //     size: AdSize.mediumRectangle,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isLinkBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );

  //   linkBannerAd.load();
  // }

  void _createInlineBannerAd() {
    inlineBannerAd = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: AdHelper.libraryBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isInlineBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    inlineBannerAd.load();
  }

  int getListViewItemIndex(int index) {
    if (index >= inlineAdIndex &&
        isInlineBannerAdLoaded.isTrue &&
        (documents.length >= inlineAdIndex)) {
      return index - 1;
    }
    return index;
  }

  Future<void> findAllEncryptedFiles() async {
    await FirestoreData.getDocumentsListFromCache(
      homeController.auth.currentUser?.uid,
      documentPerPage,
      startAfter: documents.isEmpty ? null : documents.last.createdOn,
    ).then((result) {
      final bool emptyDocumentList = result.isEmpty;
      if (!getFirstData && emptyDocumentList) {
        change(null, status: RxStatus.empty());
      } else if (getFirstData && emptyDocumentList) {
        lastPage = true;
      } else {
        getFirstData = true;
        documents.addAll(result);

        change(documents, status: RxStatus.success());
      }
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    });
  }

  // void createRewardedAd() {
  //   RewardedInterstitialAd.load(
  //     adUnitId: AdHelper.rewardedAdManage,
  //     request: const AdRequest(),
  //     rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
  //       onAdLoaded: (RewardedInterstitialAd ad) {
  //         rewardedInterstitialAd = ad;
  //         rewardLoadAttempts = 0;

  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdDismissedFullScreenContent: (ad) {
  //             isRewardedAdReady.value = false;

  //             createRewardedAd();
  //           },
  //         );

  //         isRewardedAdReady.value = true;
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         // print('Failed to load a rewarded ad: ${err.message}');
  //         rewardLoadAttempts += 1;
  //         if (rewardLoadAttempts <= maxFailedLoadAttempts) {
  //           createRewardedAd();
  //         }
  //       },
  //     ),
  //   );
  // }

  @override
  void onInit() async {
    await findAllEncryptedFiles();
    _createInlineBannerAd();
    // _createBottomBannerAd();
    // _createViewsBannerAd();
    // _createLinkBannerAd();
    //createRewardedAd();
    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    inlineBannerAd.dispose();
    // topBannerAd.dispose();
    // viewsBannerAd.dispose();
    // linkBannerAd.dispose();

    //  rewardedInterstitialAd.dispose();
    super.onClose();
  }

  @override
  Future<void> onEndScroll() async {
    if (!lastPage) {
      page += 1;
      await findAllEncryptedFiles();
      Get.back();
    }
  }

  @override
  Future<void> onTopScroll() async {}
}
