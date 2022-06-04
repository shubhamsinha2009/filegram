import 'package:filegram/app/core/extensions.dart';
import 'package:get/get.dart';
import '../../../data/model/dashboard_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';

class ContentController extends GetxController {
  final dashboard = DashboardModel(dashboardList: []).obs;
  final dashboardList = [].obs;
  final isLoading = true.obs;
  final homeController = Get.find<HomeController>();
  String get uid =>
      ((Get.arguments[0] as String) + (Get.arguments[1] as String)).sort;

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
    // dashboardList.assignAll(ContentData.contentList);
    FirestoreData.getDashboard(
      collection: 'subjects',
      listName: 'subjectList',
      uid: uid,
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
