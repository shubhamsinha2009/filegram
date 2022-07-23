import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
            imageUrl: controller.homeController.user.value.photoUrl ??
                'https://cdn.pixabay.com/photo/2016/08/31/11/54/user-1633249__480.png',

            imageBuilder: (context, imageProvider) => Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image:
                    DecorationImage(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
            // errorWidget: (context, url, error) =>
            //     const Icon(Icons.account_box_rounded),
          ),
        ],
      ),
    );
  }
}
