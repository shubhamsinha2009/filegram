import 'package:filegram/app/modules/encrypt_decrypt/views/encrypt_decrypt_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filegram'),
      ),
      body: const Center(
        child: Text(
          'HomeView is working',
        ),
      ),
      drawer: const Drawer(),
      floatingActionButton: const EncryptDecryptView(),
    );
  }
}