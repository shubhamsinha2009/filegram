import 'package:get/get.dart';

import '../../home/controllers/controllers.dart';

class AppDrawerController extends GetxController {
  final homeController = Get.find<HomeController>();
  void openPlayStore() async {
    homeController.inAppReview
        .openStoreListing(appStoreId: '...', microsoftStoreId: '...');
  }

  void signOut() {
    homeController.auth.signOut();
    Get.offAllNamed('/login');
  }
}
