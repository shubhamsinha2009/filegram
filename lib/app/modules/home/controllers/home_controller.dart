import '../../no_internet/controllers/no_internet_controller.dart';
import '../../../data/model/user_model.dart';
import '../../../data/provider/firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

class HomeController extends GetxController {
  final isFileDeviceOpen = true.obs;
  final user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final firestoreData = FirestoreData();
  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;
  final selectedIndex = 0.obs;

  void onBottomBarSelected(value) {
    selectedIndex.value = value;
  }

  @override
  void onInit() async {
    if (auth.currentUser?.uid != null) {
      final String _uid = auth.currentUser?.uid ?? '';
      user(await firestoreData.getUser(_uid));
    }

    if ((await InAppUpdate.checkForUpdate()).updateAvailability ==
        UpdateAvailability.updateAvailable) {
      await InAppUpdate.performImmediateUpdate();
    }

    super.onInit();
  }
}
