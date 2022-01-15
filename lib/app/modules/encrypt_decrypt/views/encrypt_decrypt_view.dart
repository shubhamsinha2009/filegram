import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypt_decrypt_controller.dart';

class EncryptDecryptView extends GetView<EncryptDecryptController> {
  const EncryptDecryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => FloatingActionButton(
          onPressed: controller.isLoading.value ? null : controller.pickFile,
          child: controller.isLoading.value
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : const Icon(
                  Icons.upload_rounded,
                ),
        ));
  }
}
