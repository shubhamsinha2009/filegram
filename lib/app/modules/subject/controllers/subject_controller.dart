import 'package:filegram/app/core/extensions.dart';
import 'package:get/get.dart';
import '../../../data/model/dashboard_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';

class SubjectController extends GetxController {
  final dashboard = DashboardModel(dashboardList: []).obs;
  final dashboardList = [].obs;
  final homeController = Get.find<HomeController>();
  final isLoading = true.obs;

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
    // dashboardList.assignAll(SubjectData.subjectList);
    FirestoreData.getDashboard(
            collection: 'classes',
            listName: 'classList',
            uid: (Get.arguments as String).sort)
        .then((value) {
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
