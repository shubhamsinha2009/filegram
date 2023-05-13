import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/ad_helper.dart';
import '../../../data/enums/docpermission.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/model/documents_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';
import 'package:get/get.dart';

class EncryptedFileListController extends GetxController
    with StateMixin<List<DocumentModel>> {
  List<DocumentModel> documents = [];

  bool getFirstData = false;
  int page = 1;
  bool lastPage = false;
  final homeController = Get.find<HomeController>();
  final sharedEmailIds = <String>[].obs;
  String? sourceUrl;
  final TextEditingController textEditingController = TextEditingController();
  final groupValue = DocumentPermission.public.obs;
  final inlineAdIndex = 1;
  BannerAd? inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;

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

  Future<void> createInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.viewInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
            interstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialLoadAttempts += 1;
            interstitialAd = null;
            if (interstitialLoadAttempts <= maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ),
      );
    } on Exception {
      // TODO
    }
  }

// AdWidget adWidget({required AdWithView ad}) {
//     return AdWidget(ad: ad);
//   }
  Future<void> showInterstitialAd({String? uid}) async {
    try {
      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          adDismissed.value = true;
          createInterstitialAd();
        }, onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
          ad.dispose();
          createInterstitialAd();
        }, onAdShowedFullScreenContent: (InterstitialAd ad) {
          if ((uid != null) && (homeController.user.value.id != uid)) {
            FirestoreData.updateSikka(uid);
          }
        });
        interstitialAd!.show();
      }
    } on Exception {
      // TODO
    }
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
    if (isInlineBannerAdLoaded.isFalse) {
      inlineBannerAd?.load();
    }
  }

  int getListViewItemIndex(int index) {
    if (index >= inlineAdIndex &&
        isInlineBannerAdLoaded.isTrue &&
        (documents.length >= inlineAdIndex)) {
      return index - 1;
    }
    return index;
  }

  void findAllEncryptedFiles() {
    FirestoreData.getDocumentsListFromCache(
      homeController.auth.currentUser?.uid,
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

  void filterfileList(String fileName) {
    List<DocumentModel> doc = [];
    doc = documents
        .where((element) => element.documentName!
            .toLowerCase()
            .contains(fileName.toLowerCase()))
        .toList();
    if (doc.isEmpty) {
      change(null, status: RxStatus.empty());
    } else {
      change(doc, status: RxStatus.success());
    }
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

  String getSubtitle({String? bytes, required DateTime time}) {
    return '${DateFormat.yMMMMd('en_US').add_jm().format(time)} - $bytes';
  }

  @override
  void onInit() {
    findAllEncryptedFiles();
    if (isInlineBannerAdLoaded.isFalse) {
      _createInlineBannerAd();
    }
    createInterstitialAd().catchError((e) {});

    // _createBottomBannerAd();
    // _createViewsBannerAd();
    // _createLinkBannerAd();
    //createRewardedAd();
    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    inlineBannerAd?.dispose();
    interstitialAd?.dispose();
    // topBannerAd.dispose();
    // viewsBannerAd.dispose();
    // linkBannerAd.dispose();

    //  rewardedInterstitialAd.dispose();
    super.onClose();
  }
}
