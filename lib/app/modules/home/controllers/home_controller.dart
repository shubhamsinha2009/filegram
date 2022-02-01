import 'package:filegram/app/core/helpers/ad_helper.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import '../../no_internet/controllers/no_internet_controller.dart';

import '../../../data/model/user_model.dart';
import '../../../data/provider/firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final firestoreData = FirestoreData();
  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;
  AppOpenAd appOpenAd = AppOpenAd(unitId: AdHelper.appOpenAdUnitId);
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void onInit() async {
    if (auth.currentUser?.uid != null) {
      final String _uid = auth.currentUser?.uid ?? '';
      user(await firestoreData.getUser(_uid));
    }
    super.onInit();
  }

  @override
  void onReady() async {
    if (!appOpenAd.isAvailable) await appOpenAd.load();
    if (appOpenAd.isAvailable) {
      await appOpenAd.show();
      // Load a new ad right after the other one was closed
      appOpenAd.load();
    }
    super.onReady();
  }

  @override
  void onClose() {
    appOpenAd.dispose();

    super.onClose();
  }
}
