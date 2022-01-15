import 'package:get/get.dart';

import '../controllers/encrypt_decrypt_controller.dart';

class EncryptDecryptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EncryptDecryptController>(
      () => EncryptDecryptController(),
    );
  }
}
