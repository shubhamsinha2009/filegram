import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/encrypt_decrypt_controller.dart';

class EncryptDecryptView extends GetView<EncryptDecryptController> {
  const EncryptDecryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => FloatingActionButton(
          onPressed: controller.isLoading.value ? null : controller.pickFile,
          child: controller.isLoading.value
              ? Center(
                  child: Lottie.asset(
                    'assets/loading.json',
                    fit: BoxFit.fill,
                  ),
                )
              : const Icon(
                  Icons.file_upload_sharp,
                  size: 35,
                ),
        ));
  }
}
