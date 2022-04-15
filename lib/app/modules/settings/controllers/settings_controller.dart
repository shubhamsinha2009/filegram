import 'package:get/get.dart';

import '../../home/controllers/controllers.dart';

class SettingsController extends GetxController {
  final homeController = Get.find<HomeController>();

  void signOut() {
    homeController.auth.signOut();
    Get.offAllNamed('/login');
  }
}
