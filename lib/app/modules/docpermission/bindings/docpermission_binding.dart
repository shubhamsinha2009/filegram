import 'package:get/get.dart';

import '../controllers/docpermission_controller.dart';

class DocpermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocpermissionController>(
      () => DocpermissionController(),
    );
  }
}
