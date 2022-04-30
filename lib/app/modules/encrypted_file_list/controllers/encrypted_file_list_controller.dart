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
  final inlineAdIndex = 2;
  late BannerAd inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  void _createInlineBannerAd() {
    inlineBannerAd = BannerAd(
      size: AdSize.mediumRectangle,
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

  @override
  void onInit() async {
    await findAllEncryptedFiles();
    _createInlineBannerAd();
    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    inlineBannerAd.dispose();
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
