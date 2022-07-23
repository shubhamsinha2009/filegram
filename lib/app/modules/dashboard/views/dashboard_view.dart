import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      backgroundColor: Colors.white,
      color: Colors.black87,
      strokeWidth: 4,
      displacement: 150,
      edgeOffset: 0,
      onRefresh: () async {
        controller.firebaseStorage();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLines: 1,
              onChanged: (value) => controller.filterfileList(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                isDense: true,
              ),
            ),
          ),
          Obx(
            () => controller.isBottomBannerAdLoaded.isTrue
                ? SizedBox(
                    height: controller.bottomBannerAd.size.height.toDouble(),
                    width: controller.bottomBannerAd.size.width.toDouble(),
                    child: controller.adWidget(ad: controller.bottomBannerAd),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ),
          Expanded(
            child: Obx(
              () => controller.isLoading.isFalse
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 2, maxCrossAxisExtent: 250),
                      itemCount: controller.filterclassList.length,
                      itemBuilder: (context, index) => Obx(
                        () => GestureDetector(
                          onTap: () => Get.toNamed(Routes.subject,
                              arguments: controller.filterclassList[index]),
                          child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                                left: 10,
                                right: 10,
                              ),
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      controller
                                              .homeController.changeTheme.isTrue
                                          ? Colors.black54
                                          : Colors.white70,
                                      controller
                                              .homeController.changeTheme.isTrue
                                          ? Colors.black87
                                          : Colors.white,
                                    ],
                                  ),
                                  //color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: controller
                                              .homeController.changeTheme.isTrue
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade400,
                                      offset: const Offset(5, 5),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: controller
                                              .homeController.changeTheme.isTrue
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade300,
                                      offset: const Offset(-4, -4),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    )
                                  ]),
                              child: Text(
                                controller.filterclassList[index].name,
                                textScaleFactor: 1.5,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              )),
                        ),
                      ),
                    )
                  : Center(
                      child: Lottie.asset(
                      'assets/loading.json',
                      fit: BoxFit.fill,
                    )),
            ),
          ),
        ],
      ),
    );
  }
}
