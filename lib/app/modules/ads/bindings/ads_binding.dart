import 'package:get/get.dart';

import '../controllers/ads_controller.dart';

class AdsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdsController>(
      () => AdsController(),
    );
  }
}
