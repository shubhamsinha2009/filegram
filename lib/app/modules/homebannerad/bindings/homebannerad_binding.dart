import 'package:get/get.dart';

import '../controllers/homebannerad_controller.dart';

class HomeBannerAdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeBannerAdController>(
      () => HomeBannerAdController(),
    );
  }
}
