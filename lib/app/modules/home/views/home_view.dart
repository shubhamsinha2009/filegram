import 'package:filegram/app/modules/files_device/views/files_device_view.dart';
import 'package:filegram/app/modules/homebannerad/controllers/homebannerad_controller.dart';

import '../../no_internet/views/no_internet_view.dart';

import '../../encrypted_file_list/views/encrypted_file_list_view.dart';

import '../../app_drawer/views/app_drawer_view.dart';
import '../../encrypt_decrypt/views/encrypt_decrypt_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isInternetConnected.isTrue
        ? Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Text(
                  'Filegram ${controller.isFileDeviceOpen.isTrue ? 'Library' : 'Personal'}'),
              leading: IconButton(
                  onPressed: () {
                    controller.isFileDeviceOpen.toggle();
                    Get.reload<HomeBannerAdController>();
                  },
                  icon: const Icon(
                    Icons.compare_arrows_rounded,
                  )),
            ),
            body: controller.isFileDeviceOpen.isTrue
                ? const FilesDeviceView()
                : const EncryptedFileListView(),
            endDrawer: const AppDrawerView(),
            floatingActionButton: const EncryptDecryptView(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
          )
        : const NoInternetView());
  }
}
