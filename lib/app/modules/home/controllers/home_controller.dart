import 'package:filegram/app/data/model/gullak_model.dart';
import 'package:filegram/app/modules/encrypt_decrypt/controllers/controllers.dart';
import 'package:filegram/app/routes/app_pages.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:wakelock/wakelock.dart';
import '../../../core/helpers/ad_helper.dart';
import '../../../core/services/getstorage.dart';
import '../../../data/model/user_model.dart';
import '../../no_internet/controllers/no_internet_controller.dart';
import '../../../data/provider/firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_version/new_version.dart';

class HomeController extends GetxController {
  final isFileDeviceOpen = true.obs;
  final user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final firestoreData = FirestoreData();
  final isBottomBannerAdLoaded = false.obs;
  late BannerAd bottomBannerAd;
  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;
  final selectedIndex = 0.obs;
  final QuickActions quickActions = const QuickActions();
  final gullak = GullakModel().obs;
  final changeTheme = Get.isDarkMode.obs;

  void onBottomBarSelected(value) {
    selectedIndex.value = value;
  }

  // Future<void> checkJailBreak() async {
  //   bool jailbroken;

  // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     jailbroken = await FlutterJailbreakDetection.jailbroken;
  //   } on PlatformException {
  //     jailbroken = true;
  //   }

  //   if (jailbroken) {
  //     Get.defaultDialog(
  //         title: 'ALERT -- JAIL BROKEN !!!',
  //         titleStyle: const TextStyle(color: Colors.red),
  //         buttonColor: Colors.red,
  //         backgroundColor: Colors.grey[900],
  //         middleText: ' Your Phone is Not Jail Broken.',
  //         onWillPop: () async => false,
  //         barrierDismissible: false,
  //         textConfirm: 'OK ',
  //         onConfirm: () {
  //           SystemNavigator.pop();
  //         });
  //   }
  // }

  String get info =>
      '1. Swipe Left to Right to Rename\n2. Swipe Right to Left to Save & Share\n3. Dismiss in any direction to delete';

  // Future<void> checkDevelopmentMode() async {
  //   bool developerMode;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     developerMode = await FlutterJailbreakDetection.developerMode;
  //   } on PlatformException {
  //     developerMode = true;
  //   }

  //   if (developerMode) {
  //     Get.defaultDialog(
  //         title: 'ALERT --- DEVELOPER MODE ON !!!',
  //         titleStyle: const TextStyle(color: Colors.red, fontSize: 20),
  //         // buttonColor: Colors.redAccent,
  //         backgroundColor: Colors.grey[900],
  //         // cancelTextColor: Colors.redAccent,
  //         middleText: 'Please Make Sure Developer Mode is Off.',
  //         onWillPop: () async => false,
  //         barrierDismissible: false,
  //         textConfirm: 'Close',
  //         onConfirm: () async {
  //           if (await FlutterJailbreakDetection.developerMode) {
  //             AppSettings.openDevelopmentSettings(asAnotherTask: true);
  //           } else {
  //             Get.back();
  //           }
  //         });
  //   }
  // }

  void _createBottomBannerAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bottomBanner,
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
    bottomBannerAd.load();
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  @override
  void onInit() async {
    try {
      if (auth.currentUser?.uid != null) {
        final String _uid = auth.currentUser?.uid ?? '';
        gullak.bindStream(firestoreData.getGullak(_uid));
        // user(await firestoreData.getUser(_uid));
        user(UserModel(
          id: auth.currentUser?.uid,
          emailId: auth.currentUser?.email,
          photoUrl: auth.currentUser?.photoURL,
          name: auth.currentUser?.displayName,
          phoneNumber: auth.currentUser?.phoneNumber,
        ));
      }

      _createBottomBannerAd();

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

    // if (kReleaseMode) {
    //   await checkDevelopmentMode();
    // }
    // await checkJailBreak();
    ever(
        changeTheme,
        (_) => GetStorageDbService.getWrite(
            key: 'darkmode', value: changeTheme.value));
    Wakelock.toggle(enable: true);

    super.onInit();
  }

  @override
  void onReady() {
    try {
      final newVersion = NewVersion(androidId: "com.sks.filegram");
      if (Get.context != null) {
        newVersion.getVersionStatus().then((status) {
          if (status != null && (status.localVersion != status.storeVersion)) {
            newVersion.showUpdateDialog(
              context: Get.context!,
              versionStatus: status,
              dialogTitle: 'Update Available',
              dialogText:
                  "What's New!\n${status.releaseNotes}\n You can now update this app from ${status.localVersion} to ${status.storeVersion}",
            );
          }
        }).catchError((e) {});
      }
    } catch (e) {}

    super.onReady();
  }

  @override
  void onClose() {
    bottomBannerAd.dispose();

    super.onClose();
  }
}
