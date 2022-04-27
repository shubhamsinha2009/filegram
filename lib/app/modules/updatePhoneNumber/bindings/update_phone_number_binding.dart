import 'package:get/get.dart';

import '../controllers/update_phone_number_controller.dart';

class UpdatePhoneNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdatePhoneNumberController>(
      () => UpdatePhoneNumberController(),
    );
  }
}
