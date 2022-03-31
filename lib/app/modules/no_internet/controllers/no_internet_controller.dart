import 'package:get/get.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class NoInternetController extends GetxController {
  final isInternetConnected = true.obs;
  final SimpleConnectionChecker _simpleConnectionChecker =
      SimpleConnectionChecker()..setLookUpAddress('pub.dev');
  @override
  void onInit() {
    isInternetConnected.bindStream(_simpleConnectionChecker.onConnectionChange);
    SimpleConnectionChecker.isConnectedToInternet()
        .then((value) => isInternetConnected.value = value);
    super.onInit();
  }

  @override
  void onClose() {
    isInternetConnected.close();
    super.onClose();
  }
}
