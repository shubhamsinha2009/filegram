import 'package:filegram/app/data/model/gullak_model.dart';
import 'package:filegram/app/modules/encrypt_decrypt/controllers/controllers.dart';
import 'package:filegram/app/routes/app_pages.dart';
import 'package:new_version/new_version.dart';
import 'package:quick_actions/quick_actions.dart';

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
  final newVersion = NewVersion(forceAppVersion: "1.1.0+30");

  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;
  final selectedIndex = 0.obs;
  final QuickActions quickActions = const QuickActions();
  final gullak = GullakModel().obs;
  void onBottomBarSelected(value) {
    selectedIndex.value = value;
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
    super.onInit();
  }
}
