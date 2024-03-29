import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filegram/app/core/services/new_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Obx(
        //   () => UserAccountsDrawerHeader(

        //     accountName: Text(
        //       '${controller.homeController.user.value.name}',
        //     ),
        //     accountEmail: Text(
        //       '${controller.homeController.user.value.emailId}\n${controller.homeController.user.value.phoneNumber}',
        //     ),
        //     // otherAccountsPictures: const [Icon(Icons.edit)],
        //     currentAccountPicture: CachedNetworkImage(
        //       imageUrl: controller.homeController.user.value.photoUrl ??
        //           'https://cdn.pixabay.com/photo/2016/08/31/11/54/user-1633249__480.png',
        //       errorWidget: (context, url, error) =>
        //           const Icon(Icons.account_box_rounded),
        //     ),

        //     // onDetailsPressed: () => Get.toNamed(Routes.profile),
        //   ),
        // ),
        ListTile(
          // tileColor: Colors.blueGrey.shade500,
          title: Obx(() => Text(
                '${controller.homeController.user.value.name}',
              )),
          subtitle: Obx(() => Text(
                '${controller.homeController.user.value.emailId}\n${controller.homeController.user.value.phoneNumber}',
              )),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              controller.homeController.user.value.photoUrl ??
                  'https://cdn.pixabay.com/photo/2016/08/31/11/54/user-1633249__480.png',
            ),
          ),
        ),
        Obx(
          () => controller.isSettingsBannerAdLoaded.isTrue
              ? SizedBox(
                  height: controller.settingsBannerAd?.size.height.toDouble(),
                  width: controller.settingsBannerAd?.size.width.toDouble(),
                  child: controller.adWidget(ad: controller.settingsBannerAd!),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
        ),
        ListTile(
          title: const Text(
            'Update Phone Number',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: const Icon(
            Icons.phone_android_outlined,
          ),
          onTap: () => Get.toNamed(Routes.updatePhoneNumber),
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
                await launchUrlString(
                    "https://play.google.com/store/apps/details?id=com.sks.filegram",
                    mode: LaunchMode.externalNonBrowserApplication);
              } on PlatformException {
                Get.showSnackbar(GetSnackBar(
                  backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                  messageText: const Text('Unable to open App'),
                  icon: const Icon(Icons.error_outline),
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3),
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
              "Send your pdf files through Filegram  -- Check Out Filegram here for many more exciting features for you ----  https://play.google.com/store/apps/details?id=com.sks.filegram"),
        ),

        ListTile(
          onTap: () {
            final newVersion = NewVersionPlus(androidId: "com.sks.filegram");
            if (Get.context != null) {
              newVersion.getVersionStatus().then((status) {
                if (status != null &&
                    (status.localVersion != status.storeVersion)) {
                  newVersion.showUpdateDialog(
                    context: Get.context!,
                    versionStatus: status,
                    dialogTitle: 'Update Available',
                    dialogText:
                        "What's New!\n${status.releaseNotes}\n You can now update this app from ${status.localVersion} to ${status.storeVersion}",
                  );
                } else {
                  Get.showSnackbar(GetSnackBar(
                    backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                    messageText:
                        Text("You have latest version ${status?.localVersion}"),
                    icon: const Icon(Icons.error_outline),
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 3),
                  ));
                }
              });
            }
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
          onTap: () async {
            try {
              await launchUrlString(
                "https://docs.google.com/forms/d/e/1FAIpQLSfjp_SNlap2NRH6lwZOb0iHrSrxsdsI2gH9IITMwxFPZUh1fw/viewform?usp=sf_link",
                mode: LaunchMode.externalApplication,
              );
            } on PlatformException {
              Get.showSnackbar(GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('Unable to open '),
                icon: const Icon(Icons.error_outline),
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 3),
              ));
            }
          },
          leading: const Icon(Icons.feedback),
          title: const Text(
            'Feedback',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListTile(
          onTap: () async {
            try {
              await launchUrlString(
                "https://sites.google.com/view/filegram/privacypolicy",
              );
            } on PlatformException {
              Get.showSnackbar(GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('Unable to open '),
                icon: const Icon(Icons.error_outline),
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 3),
              ));
            }
          },
          leading: const Icon(Icons.privacy_tip),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        ListTile(
          onTap: () async {
            try {
              await launchUrlString(
                "https://sites.google.com/view/filegram/terms_and_conditions",
              );
            } on PlatformException {
              Get.showSnackbar(GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('Unable to open '),
                icon: const Icon(Icons.error_outline),
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 3),
              ));
            }
          },
          leading: const Icon(Icons.note_alt),
          title: const Text(
            'Terms And Conditions',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListTile(
          onTap: () => AppSettings.openAppSettings(),
          leading: const Icon(
            Icons.app_settings_alt,
          ),
          title: const Text(
            'App Settings',
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

        ListTile(
          onTap: () async {
            try {
              await launchUrlString(
                "https://sites.google.com/view/filegram",
              );
            } on PlatformException {
              Get.showSnackbar(GetSnackBar(
                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                messageText: const Text('Unable to open '),
                icon: const Icon(Icons.error_outline),
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 3),
              ));
            }
          },
          leading: const Icon(Icons.web),
          title: const Text(
            'Our Website',
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
