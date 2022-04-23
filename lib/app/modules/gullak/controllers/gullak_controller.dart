import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';

class GullakController extends GetxController {
  final gullak = Get.find<HomeController>().gullak;

  double? getLinearValue(int sikka) {
    return (sikka / 1000);
  }
}
