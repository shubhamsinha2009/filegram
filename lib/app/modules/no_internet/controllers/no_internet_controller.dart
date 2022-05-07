import 'package:get/get.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class NoInternetController extends GetxController {
  final isInternetConnected = true.obs;
  SimpleConnectionChecker simpleConnectionChecker = SimpleConnectionChecker();
  @override
  void onInit() {
    isInternetConnected.bindStream(simpleConnectionChecker.onConnectionChange);
    SimpleConnectionChecker.isConnectedToInternet()
        .then((value) => isInternetConnected.value = value)
        .catchError((e) {});
    super.onInit();
  }

  @override
  void onClose() {
    isInternetConnected.close();
    super.onClose();
  }
}
