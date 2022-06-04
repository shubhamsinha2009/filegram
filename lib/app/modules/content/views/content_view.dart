import 'package:filegram/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/content_controller.dart';

class ContentView extends GetView<ContentController> {
  const ContentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Get.arguments[1]} Books'),
        actions: [
          IconButton(
              onPressed: () {
                Get.changeThemeMode(
                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                controller.homeController.changeTheme.toggle();
              },
              icon: Icon(
                controller.homeController.changeTheme.isTrue
                    ? Icons.light_mode
                    : Icons.dark_mode,
              )),
        ],
      ),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        backgroundColor: Colors.white,
        color: Colors.black87,
        strokeWidth: 4,
        displacement: 150,
        edgeOffset: 0,
        onRefresh: () async {
          controller.onInitialisation();
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
                  hintText: 'Search By Book',
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => controller.isLoading.isFalse
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                childAspectRatio: 2, maxCrossAxisExtent: 250),
                        itemCount: controller.dashboardList.length,
                        itemBuilder: (context, index) => Obx(
                          () => GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.book, arguments: [
                                controller.uid,
                                controller.dashboardList[index]
                              ]);
                            },
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
                                controller.dashboardList[index],
                                textScaleFactor: 1.3,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
