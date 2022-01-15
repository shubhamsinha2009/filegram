import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypt_decrypt_controller.dart';

class EncryptDecryptView extends GetView<EncryptDecryptController> {
  const EncryptDecryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoading.value
        ? const FloatingActionButton.extended(
            onPressed: null,
            label: Text('Loading'),
            icon: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
        : FloatingActionButton.extended(
            onPressed: controller.pickFile,
            icon: const Icon(
              Icons.upload_rounded,
            ),
            label: const Text('Choose Files'),
          ));
  }
}
