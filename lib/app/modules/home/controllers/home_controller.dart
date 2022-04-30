import 'dart:async';

import 'package:filegram/app/data/model/gullak_model.dart';
import 'package:filegram/app/modules/encrypt_decrypt/controllers/controllers.dart';
import 'package:filegram/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:new_version/new_version.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:wakelock/wakelock.dart';

import '../../no_internet/controllers/no_internet_controller.dart';
import '../../../data/model/user_model.dart';
import '../../../data/provider/firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final isFileDeviceOpen = true.obs;
  final user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final firestoreData = FirestoreData();

  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;
  final selectedIndex = 0.obs;
  final QuickActions quickActions = const QuickActions();
  final gullak = GullakModel().obs;
  void onBottomBarSelected(value) {
    selectedIndex.value = value;
  }

  Future<void> checkJailBreak() async {
    bool jailbroken;
    bool developerMode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } on PlatformException {
      jailbroken = true;
      developerMode = true;
    }
    if (jailbroken || developerMode) {
      Get.showSnackbar(const GetSnackBar(
        message:
            'Please Make Sure Developer Mode is Off and Your Phone is Not Jail Broked',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      ));
      Timer(const Duration(seconds: 5), (() => SystemNavigator.pop()));
    }
  }

  @override
  void onInit() async {
    try {
      if (auth.currentUser?.uid != null) {
        final String _uid = auth.currentUser?.uid ?? '';
        gullak.bindStream(firestoreData.getGullak(_uid));
        user(await firestoreData.getUser(_uid));
      }

      quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
            type: 'click_to_chat',
            localizedTitle: 'Whatsapp Click to Chat',
            icon: 'icon_whatsapp'),
        const ShortcutItem(
            type: 'action_upload_file',
            localizedTitle: 'Upload File(Pdf)',
            icon: 'icon_upload')
      ]);

      quickActions.initialize((shortcutType) {
        if (shortcutType == 'click_to_chat') {
          Get.toNamed(Routes.whatsappChat);
        } else if (shortcutType == 'action_upload_file') {
          Get.find<EncryptDecryptController>().pickFile();
        }
        // TODO: More handling code...
      });
    } catch (e) {
      //TODO: do nothing
    }

    if (kReleaseMode) {
      await checkJailBreak();
    }

    Wakelock.toggle(enable: true);

    super.onInit();
  }

  @override
  void onReady() async {
    // TODO : Implemnt firestore false allow dissmisal
    final newVersion = NewVersion();
    if (Get.context != null) {
      newVersion.showAlertIfNecessary(context: Get.context!);
    }
    super.onReady();
  }
}
