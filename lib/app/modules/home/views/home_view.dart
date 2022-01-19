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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filegram'),
      ),
      body: const EncryptedFileListView(),
      drawer: const AppDrawerView(),
      floatingActionButton: const EncryptDecryptView(),
    );
  }
}
