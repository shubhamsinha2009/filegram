import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:filegram/app/modules/files_device/views/files_device_view.dart';

import '../../../routes/app_pages.dart';
import '../../encrypt_decrypt/views/encrypt_decrypt_view.dart';
import '../../encrypted_file_list/views/encrypted_file_list_view.dart';
import '../../no_internet/views/no_internet_view.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyPages = [
      const FilesDeviceView(),
      const EncryptedFileListView(),
      const SettingsView(),
    ];
    return Obx(
      () => controller.isInternetConnected.isTrue
          ? Scaffold(
              appBar: AppBar(
                title: const FittedBox(child: Text('Filegram')),

                leading: Image.asset(
                  "assets/app_bar.png",
                ),
                // leadingWidth: 0,
                titleSpacing: 0,

                actions: [
                  controller.selectedIndex.value == 0
                      ? IconButton(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                alignment: Alignment.center,
                                backgroundColor: Get.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                title: const Icon(Icons.info),
                                content: Text(
                                  controller.info,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      if (Get.isOverlaysOpen) {
                                        Get.back();
                                      }
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.info,
                          ))
                      : const SizedBox(
                          height: 0,
                          width: 0,
                        ),
                  IconButton(
                      onPressed: () {
                        Get.changeThemeMode(
                            Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                        controller.changeTheme.toggle();
                      },
                      icon: Icon(
                        controller.changeTheme.isTrue
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      )),
                  ActionChip(
                    onPressed: () {
                      Get.toNamed(Routes.gullak);
                    },
                    label: Row(
                      children: [
                        Text('${controller.gullak.value.sikka}'),
                        const Icon(Icons.circle, color: Colors.amber),
                      ],
                    ),
                    avatar: const Icon(Icons.savings_rounded,
                        color: Color.fromARGB(255, 194, 103, 70)),
                    labelPadding: const EdgeInsets.only(
                      left: 5,
                    ),
                  ),
                ],
              ),
              persistentFooterButtons: [
                controller.isBottomBannerAdLoaded.isTrue
                    ? SizedBox(
                        height:
                            controller.bottomBannerAd.size.height.toDouble(),
                        width: controller.bottomBannerAd.size.width.toDouble(),
                        child:
                            controller.adWidget(ad: controller.bottomBannerAd),
                      )
                    : const SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ],
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
                    icon: Icon(Icons.analytics),
                    label: 'My Files',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.manage_accounts),
                    label: 'Settings',
                  ),
                ],
                selectedIndex: controller.selectedIndex.value,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: controller.onBottomBarSelected,
              ),
            )
          : const NoInternetView(),
    );
  }
}
