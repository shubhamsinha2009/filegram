import 'package:get/get.dart';

import '../../../data/model/dashboard_model.dart';
import '../../../data/model/promotional.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final isLoadingPromotional = true.obs;
  final dashboard = DashboardModel(dashboardList: []).obs;
  final dashboardList = [].obs;
  final thumbnailLinks = [].obs;
  final shareUrls = [].obs;
  final homeController = Get.find<HomeController>();
  void filterfileList(String fileName) {
    if (fileName.isEmpty) {
      dashboardList.assignAll(dashboard.value.dashboardList);
    } else {
      dashboardList.assignAll(dashboard.value.dashboardList
          .where((String element) =>
              element.toLowerCase().contains(fileName.toLowerCase()))
          .toList());
    }
  }

  void onInitialisation({required bool isCache}) {
    // dashboardList.assignAll(DashboardData.dashboardList);

    FirestoreData.getDashboard(
      collection: 'dashboard',
      listName: 'dashboardList',
      uid: 'dashboard',
      isCache: isCache,
    ).then((value) {
      dashboard(value);
      dashboardList.assignAll(dashboard.value.dashboardList);
    }).whenComplete(() {
      isLoading.value = false;
    }).catchError((e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    });
    FirestoreData.getPromotionalLinks().then((Promotional promotional) {
      shareUrls.assignAll(promotional.shareUrls);
      thumbnailLinks.assignAll(promotional.thumbnailLinks);
    }).whenComplete(() {
      isLoadingPromotional.value = false;
    }).catchError((e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    });
  }

  @override
  void onInit() {
    onInitialisation(isCache: true);
    super.onInit();
  }
}
