import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:new_version/new_version.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Obx(
          () => UserAccountsDrawerHeader(
            accountName: Text(
              controller.homeController.user.value.name ?? 'User Name',
            ),
            accountEmail: Text(
              controller.homeController.user.value.emailId ?? 'User Email Id',
            ),
            currentAccountPicture: CachedNetworkImage(
              imageUrl: controller.homeController.user.value.photoUrl ??
                  'https://cdn.pixabay.com/photo/2016/08/31/11/54/user-1633249__480.png',
              errorWidget: (context, url, error) =>
                  const Icon(Icons.account_box_rounded),
            ),
          ),
        ),
        // ListTile(
        //   title: const Text(
        //     'Update Phone Number',
        //     style: TextStyle(
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        //   leading: const Icon(
        //     Icons.phone_android_outlined,
        //   ),
        //   onTap: () => Get.toNamed(Routes.updatePhoneNumber),
        // ),
        ListTile(
          title: const Text(
            'Whatsapp Click to Chat',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: const Icon(
            Icons.whatsapp_outlined,
          ),
          onTap: () => Get.toNamed(Routes.whatsappChat),
        ),
        ListTile(
          title: const Text(
            'Gullak',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: const Icon(
            Icons.savings_outlined,
          ),
          onTap: () => Get.toNamed(Routes.gullak),
        ),
        controller.isSettingsBannerAdLoaded.isTrue
            ? SizedBox(
                height: controller.settingsBannerAd.size.height.toDouble(),
                width: controller.settingsBannerAd.size.width.toDouble(),
                child: controller.adWidget(ad: controller.settingsBannerAd),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        ListTile(
            title: const Text(
              'Rate Us',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: const Icon(
              Icons.rate_review_outlined,
            ),
            onTap: () async {
              try {
                await launch(
                    "https://play.google.com/store/apps/details?id=com.sks.filegram");
              } on PlatformException {
                Get.showSnackbar(const GetSnackBar(
                  messageText: Text('Unable to open App'),
                  icon: Icon(Icons.error_outline),
                  snackPosition: SnackPosition.TOP,
                  duration: Duration(seconds: 3),
                ));
              }
            }),
        ListTile(
          title: const Text(
            'Share Filegram',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: const Icon(
            Icons.share_outlined,
          ),
          onTap: () => Share.share(
              "Send your pdf files through filegram and earn money -- Check Out Filegram here for many more exciting features for you ----  https://play.google.com/store/apps/details?id=com.sks.filegram"),
        ),
        ListTile(
          onTap: () async {
            final newVersion = NewVersion();
            newVersion.showAlertIfNecessary(context: context);
          },
          leading: const Icon(Icons.system_update_outlined),
          title: const Text(
            'Check For Update',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListTile(
          onTap: controller.signOut,
          leading: const Icon(
            Icons.logout_outlined,
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // ListTile(
        //   onTap: controller.openPlayStore,
        //   title: const Text('Open App in Play Store'),
        // ),
      ],
    );
  }
}
