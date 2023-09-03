import 'package:filegram/app/modules/login/widgets/no_cloud.dart';
import 'package:filegram/app/modules/login/widgets/passwordless.dart';
import 'package:filegram/app/modules/login/widgets/pocket_pdf.dart';
import '../../no_internet/views/no_internet_view.dart';
import '../controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../widgets/google_login.dart';
import '../widgets/gullak.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      PocketPdf(controller: controller),
      Gullak(controller: controller),
      NoCloud(controller: controller),
      PasswordlessEncryption(controller: controller),
      GoogleLogin(controller: controller),
    ];
    final lastpage = items.length - 1;
    return Obx(() => controller.isInternetConnected.isTrue
        ? Scaffold(
            body: SafeArea(
              child: FlutterCarousel(
                options: CarouselOptions(
                    height: context.height - 200,
                    enableInfiniteScroll: false,
                    autoPlay: true,
                    initialPage: 0,
                    aspectRatio: 9 / 16,
                    showIndicator: false,
                    viewportFraction: 1,
                    controller: controller.buttonCarouselController,
                    // enlargeCenterPage: true,

                    floatingIndicator: false,
                    onPageChanged: (page, reason) =>
                        controller.page.value = page),
                items: items,
              ),
            ),
            bottomSheet: controller.page.value == lastpage
                ? null
                : Container(
                    margin: const EdgeInsets.all(20),
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Get.isDarkMode ? Colors.black87 : Colors.white70,
                            Get.isDarkMode ? Colors.black54 : Colors.white54,
                          ],
                        ),
                        //color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade900,
                            offset: const Offset(5, 5),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.grey.shade800,
                            offset: const Offset(-4, -4),
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ]),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 20,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) => Container(
                              height: 10,
                              width: 10,
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (index == controller.page.value)
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                controller.buttonCarouselController
                                    .jumpToPage(lastpage);
                              },
                              child: const Text('SKIP'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.buttonCarouselController
                                    .previousPage();
                              },
                              child: const Text('PREVIOUS'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.buttonCarouselController.nextPage();
                              },
                              child: const Text('NEXT'),
                            )
                          ],
                        ),
                      ],
                    )),
          )
        : const NoInternetView());
  }
}
