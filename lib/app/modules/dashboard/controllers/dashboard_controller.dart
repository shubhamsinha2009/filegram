import 'package:get/get.dart';

import '../../../data/model/dashboard_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final dashboard = DashboardModel(dashboardList: []).obs;
  final dashboardList = [].obs;
  final homeController = Get.find<HomeController>();
  void filterfileList(String fileName) {
    if (fileName.isEmpty) {
      dashboardList.assignAll(dashboard.value.dashboardList.reversed);
    } else {
      dashboardList.assignAll(dashboard.value.dashboardList.reversed
          .where((String element) =>
              element.toLowerCase().contains(fileName.toLowerCase()))
          .toList());
    }
  }

  void onInitialisation() {
    // dashboardList.assignAll(DashboardData.dashboardList);
    FirestoreData.getDashboard(
      collection: 'dashboard',
      listName: 'dashboardList',
      uid: 'dashboard',
    ).then((value) {
      dashboard(value);
      dashboardList.assignAll(dashboard.value.dashboardList.reversed);
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
  }

  @override
  void onInit() {
    onInitialisation();
    super.onInit();
  }
}
