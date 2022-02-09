import 'package:get/get.dart';

import '../controllers/files_device_controller.dart';

class FilesDeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FilesDeviceController>(
      () => FilesDeviceController(),
    );
  }
}
