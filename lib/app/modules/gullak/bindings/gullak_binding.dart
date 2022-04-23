import 'package:get/get.dart';

import '../controllers/gullak_controller.dart';

class GullakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GullakController>(
      () => GullakController(),
    );
  }
}
