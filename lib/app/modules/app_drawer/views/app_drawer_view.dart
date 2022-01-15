import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/app_drawer_controller.dart';

class AppDrawerView extends GetView<AppDrawerController> {
  const AppDrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(
            () => UserAccountsDrawerHeader(
              accountName: Text(
                controller.homeController.user.value.name ?? 'User Name',
              ),
              accountEmail: Text(
                controller.homeController.user.value.emailId
                        ?.replaceAll('@gmail.com', '') ??
                    'User ID',
              ),
              currentAccountPicture: CachedNetworkImage(
                imageUrl: controller.homeController.user.value.photoUrl ??
                    'https://cdn.pixabay.com/photo/2016/08/31/11/54/user-1633249__480.png',
                errorWidget: (context, url, error) =>
                    const Icon(Icons.account_box_rounded),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              controller.homeController.auth.signOut();
              Get.offAllNamed('/login');
            },
            leading: const Icon(Icons.logout_rounded),
            title: const Text('LogOut'),
          ),
        ],
      ),
    );
  }
}
