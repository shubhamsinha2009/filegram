import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypt_decrypt_controller.dart';

class EncryptDecryptView extends GetView<EncryptDecryptController> {
  const EncryptDecryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => FloatingActionButton.extended(
          onPressed: controller.isLoading ? null : controller.chooseFiles,
          label: controller.isLoading
              ? const Text(
                  'Loading',
                  textScaleFactor: 1.5,
                )
              : const Text(
                  'Choose File',
                  textScaleFactor: 1.5,
                ),
          icon: controller.isLoading
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : const Icon(
                  Icons.upload_file_rounded,
                ),
        ));
  }
}
