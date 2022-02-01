import 'package:native_admob_flutter/native_admob_flutter.dart';

import '../../../data/enums/docpermission.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/model/documents_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';
import 'package:get/get.dart';

class EncryptedFileListController extends GetxController
    with StateMixin<List<DocumentModel>>, ScrollMixin {
  List<DocumentModel> documents = [];
  final int documentPerPage = 10;
  bool getFirstData = false;
  int page = 1;
  bool lastPage = false;
  final homeController = Get.find<HomeController>();
  final sharedEmailIds = <String>[].obs;
  final TextEditingController textEditingController = TextEditingController();
  // final String? _ownerId = Get.find<HomeController>().auth.currentUser?.uid;
  final groupValue = DocumentPermission.public.obs;
  final nativeAdController = NativeAdController();

  @override
  void onInit() async {
    await findAllEncryptedFiles();
    super.onInit();
  }

  Future<void> requestInAppReview() async {
    if (await homeController.inAppReview.isAvailable()) {
      homeController.inAppReview.requestReview();
    }
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
  void onClose() {
    textEditingController.dispose();
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
