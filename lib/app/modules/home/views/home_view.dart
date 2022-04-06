import 'package:filegram/app/modules/files_device/views/files_device_view.dart';

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
    List<Widget> bodyPages = [
      const FilesDeviceView(),
      const EncryptedFileListView(),
      const AppDrawerView(),
    ];
    return Obx(
      () => controller.isInternetConnected.isTrue
          ? Scaffold(
              appBar: AppBar(
                title: const Text('Filegram'),
                leading: Image.asset(
                  "assets/app_bar.png",
                ),
              ),
              body: bodyPages[controller.selectedIndex.value],
              floatingActionButton: const EncryptDecryptView(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniEndFloat,
              bottomNavigationBar: NavigationBar(
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.library_books),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.tips_and_updates_outlined),
                      label: 'Manage Encrypted',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                  selectedIndex: controller.selectedIndex.value,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: controller.onBottomBarSelected),
            )
          : const NoInternetView(),
    );
  }
}
