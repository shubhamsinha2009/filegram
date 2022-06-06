import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../controllers/dashboard_controller.dart';

class PromotionCarousel extends StatelessWidget {
  const PromotionCarousel({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final DashboardController controller;
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoadingPromotional.isFalse
        ? FlutterCarousel.builder(
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              autoPlay: true,
              initialPage: 0,
              enlargeCenterPage: true,
              //viewportFraction: 0.9,
              // pauseAutoPlayOnTouch: false,
              // autoPlayInterval: const Duration(seconds: 1),
              //showIndicator: false,
            ),
            itemCount: controller.thumbnailLinks.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              return GestureDetector(
                onTap: () async {
                  final String? urlString = controller.shareUrls[itemIndex];
                  if (urlString != null && urlString.isNotEmpty) {
                    await launchUrlString(urlString,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: controller.thumbnailLinks[itemIndex],
                        fit: BoxFit.fill,
                        width: double.infinity,
                        alignment: Alignment.center,

                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        // height: 200,
                        placeholder: (context, _) => Container(
                            height: context.height,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.white38,
                                      Colors.white54,
                                    ]))),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          '${itemIndex + 1}/${controller.thumbnailLinks.length}',
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: IconButton(
                    //     icon: Icon(Icons.forward),
                    //     onPressed: () {
                    //       buttonCarouselController.nextPage(
                    //           duration: Duration(milliseconds: 300),
                    //           curve: Curves.linear);
                    //     },
                    //   ),
                    // )
                  ],
                ),
              );
            })
        : Center(
            child: Lottie.asset(
              'assets/loading.json',
              fit: BoxFit.fill,
            ),
          ));
  }
}
