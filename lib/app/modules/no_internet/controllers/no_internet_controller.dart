import 'package:get/get.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class NoInternetController extends GetxController {
  final isInternetConnected = true.obs;
  final SimpleConnectionChecker _simpleConnectionChecker =
      SimpleConnectionChecker();
  @override
  void onInit() async {
    isInternetConnected.bindStream(_simpleConnectionChecker.onConnectionChange);
    isInternetConnected.value =
        await SimpleConnectionChecker.isConnectedToInternet();
    super.onInit();
  }

  @override
  void onClose() {
    isInternetConnected.close();
    super.onClose();
  }
}
