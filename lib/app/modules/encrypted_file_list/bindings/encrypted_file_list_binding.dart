import 'package:get/get.dart';

import '../controllers/encrypted_file_list_controller.dart';

class EncryptedFileListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EncryptedFileListController>(
      () => EncryptedFileListController(),
    );
  }
}
