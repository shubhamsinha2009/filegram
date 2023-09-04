import 'package:filegram/app/modules/no_internet/views/no_internet_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/view_pdf_controller.dart';
import 'package:alh_pdf_view/lib.dart';

class ViewPdfView extends GetView<ViewPdfController> {
  const ViewPdfView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isInternetConnected.isTrue
        ? Scaffold(
            body: Stack(alignment: Alignment.center, children: [
              Obx(
                () => controller.isDecryptionDone.isFalse
                    ? Center(
                        child: Lottie.asset(
                          'assets/loading.json',
                          fit: BoxFit.fill,
                        ),
                      )
                    : AlhPdfView(
                        key: GlobalKey(),
                        filePath: controller.fileOut,
                        // pdfData: File(controller.fileOut).readAsBytesSync(),
                        enableSwipe: true,
                        swipeHorizontal: controller.swipehorizontal.value,
                        autoSpacing: true,
                        pageFling: true,
                        pageSnap: true,
                        nightMode: controller.changeTheme.value,
                        fitEachPage: true,
                        fitPolicy: FitPolicy.both,
                        defaultPage: controller.intialPageNumber,
                        minZoom: 1,
                        maxZoom: 5,
                        enableDefaultScrollHandle: false,

                        enableDoubleTap: true,

                        onRender: (pages) {
                          controller.totalPages.value = pages;
                        },
                        onError: (error) {
                          Get.dialog(
                            AlertDialog(
                              alignment: Alignment.center,
                              backgroundColor:
                                  Get.isDarkMode ? Colors.black : Colors.white,
                              title: const Icon(Icons.error_outline),
                              content: Text(
                                error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    if (Get.isOverlaysOpen) {
                                      Get.back(
                                          closeOverlays: true, canPop: true);
                                    }
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                            barrierDismissible: false,
                          );
                        },
                        onPageError: (page, error) {
                          Get.showSnackbar(GetSnackBar(
                            backgroundColor:
                                Get.theme.snackBarTheme.backgroundColor!,
                            messageText: Text(
                                'The Page $page has an error : ${error.toString()}'),
                            icon: const Icon(Icons.error_outline),
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 3),
                          ));
                        },
                        onViewCreated:
                            (AlhPdfViewController pdfViewController) {
                          // controller.pdfController.complete(pdfViewController);
                          controller.pdfViewController = pdfViewController;
                        },

                        onPageChanged: (int? page, int? total) {
                          if (page != null && total != null) {
                            controller.intialPageNumber = page;
                            controller.currentPage.value = page;
                            controller.pageTimer = 0;
                            //  controller.lastChanged = controller.pageTimer;
                          }

                          ///  print('page change: /');
                        },
                      ),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => controller.handleTapNextPage(),
                    child: Container(
                      height: 400,
                      width: 80,
                      color: Colors.transparent,
                    ),
                  )),
              Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => controller.handleTapPreviousPage(),
                    child: Container(
                      height: 400,
                      width: 80,
                      color: Colors.transparent,
                    ),
                  )),
              Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => controller.hideAppBar.toggle(),
                    child: Container(
                      height: 400,
                      width: 180,
                      color: Colors.transparent,
                    ),
                  )),
              Align(
                  alignment: Alignment.topCenter,
                  child: Obx(
                    () => controller.hideAppBar.isFalse
                        ? Container(
                            width: double.infinity,
                            height: 100,
                            color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () => Get.back(),
                                    icon: const Icon(Icons.arrow_back)),
                                Obx(() =>
                                    controller.isInterstitialAdLoaded.isTrue
                                        ? Chip(
                                            label: Text(
                                              'Ad in ${controller.countdownTimer.value} sec',
                                              softWrap: true,
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 0,
                                            width: 0,
                                          )),
                                IconButton(
                                    onPressed: () async =>
                                        await Share.shareXFiles(
                                          [XFile(controller.filePath)],
                                          text:
                                              'Download Filegram to open this file 🔓- https://play.google.com/store/apps/details?id=com.sks.filegram',
                                        ),
                                    icon: const Icon(Icons.share)),
                                Obx(() => IconButton(
                                    onPressed: () {
                                      controller.changeTheme.toggle();
                                    },
                                    icon: Icon(
                                      controller.changeTheme.isTrue
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                    ))),
                                IconButton(
                                    onPressed: () {
                                      controller.swipehorizontal.toggle();
                                    },
                                    icon: const Icon(
                                        Icons.rotate_90_degrees_ccw_outlined)),
                              ],
                            ),
                          )
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Obx(
                  () => controller.hideAppBar.isFalse
                      ? Container(
                          color: Colors.black,
                          width: double.infinity,
                          height: 100,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: [
                              Obx(
                                () => controller.isBottomBannerAdLoaded.isTrue
                                    ? SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: controller.adWidget(
                                            ad: controller.bottomBannerAd!),
                                      )
                                    : const SizedBox(
                                        height: 0,
                                        width: 0,
                                      ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: controller.handleTapZoomOut,
                                    icon: const Icon(Icons.zoom_out),
                                  ),
                                  IconButton(
                                    onPressed: controller.undoPage,
                                    icon: const Icon(Icons.undo_rounded),
                                  ),
                                  IconButton(
                                    onPressed: controller.handleTapPreviousPage,
                                    icon: const Icon(Icons.navigate_before),
                                  ),
                                  ActionChip(
                                    label: Obx(() => Text(
                                        "${controller.currentPage.value + 1}/${controller.totalPages}")),
                                    onPressed: () {
                                      Get.dialog(AlertDialog(
                                        title: const Text('Go to Page'),
                                        content: TextFormField(
                                          initialValue:
                                              '${controller.currentPage.value + 1}',
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: const InputDecoration(
                                            labelText: 'Enter page numbber',
                                          ),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          onChanged: (text) {
                                            controller.gotopage =
                                                int.tryParse(text);
                                          },
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'Can\'t be empty';
                                            }

                                            if (controller.gotopage == null) {
                                              return '"$text" is not a valid page number';
                                            } else {
                                              if (controller.gotopage! >=
                                                      controller
                                                          .totalPages.value ||
                                                  controller.gotopage! <= 0) {
                                                return 'Page Not Exist';
                                              }
                                            }
                                            return null;
                                          },
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                        backgroundColor: Get.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                        actions: [
                                          OutlinedButton(
                                              onPressed: () => Get.back(),
                                              child: const Text('Back')),
                                          OutlinedButton(
                                              onPressed: () {
                                                if (controller.gotopage !=
                                                            null &&
                                                        (controller.gotopage! <
                                                            controller
                                                                .totalPages
                                                                .value) ||
                                                    controller.gotopage! >= 0) {
                                                  Get.back();
                                                  controller.goToPage(
                                                      controller.gotopage! - 1);
                                                }
                                              },
                                              child: const Text('Go'))
                                        ],
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    onPressed: controller.handleTapNextPage,
                                    icon: const Icon(Icons.navigate_next),
                                  ),
                                  IconButton(
                                    onPressed: controller.redoPage,
                                    icon: const Icon(Icons.redo_rounded),
                                  ),
                                  IconButton(
                                    onPressed: controller.handleTappZoomIn,
                                    icon: const Icon(Icons.zoom_in),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(
                          width: 0,
                          height: 0,
                        ),
                ),
              )
              // Positioned(
              //   child: AppBar(
              //     title: Obx(() => controller.isInterstitialAdLoaded.isTrue
              //         ? Chip(
              //             label: Text(
              //               'Ad in ${controller.countdownTimer.value} sec',
              //               softWrap: true,
              //             ),
              //           )
              //         : const SizedBox(
              //             height: 0,
              //             width: 0,
              //           )),
              //     titleSpacing: 0,
              //     // Obx(() => Text(
              //     //               "${controller.currentPageNumber + 1}/${controller.pages}")),
              //     // Text("${controller.currentPageNumber + 1}/${controller.pages}")),
              //     actions: [
              //       //  Obx(() => Text('${controller.countdownTimer.value}')),

              //       IconButton(
              //           onPressed: () async => await Share.shareXFiles(
              //                 [XFile(controller.filePath)],
              //                 text:
              //                     'Download Filegram to open this file 🔓- https://play.google.com/store/apps/details?id=com.sks.filegram',
              //               ),
              //           icon: const Icon(Icons.share)),
              //       Obx(() => IconButton(
              //           onPressed: () {
              //             controller.changeTheme.toggle();
              //           },
              //           icon: Icon(
              //             controller.changeTheme.isTrue
              //                 ? Icons.light_mode
              //                 : Icons.dark_mode,
              //           ))),
              //       IconButton(
              //           onPressed: () {
              //             controller.swipehorizontal.toggle();
              //           },
              //           icon: const Icon(Icons.rotate_90_degrees_ccw_outlined)),
              //     ],
              //   ),
              // ),
              //   persistentFooterButtons: [
              //     Obx(
              //       () => controller.isBottomBannerAdLoaded.isTrue
              //           ? SizedBox(
              //               height: 50,
              //               width: double.infinity,
              //               child: controller.adWidget(
              //                   ad: controller.bottomBannerAd!),
              //             )
              //           : const SizedBox(
              //               height: 0,
              //               width: 0,
              //             ),
              //     ),
              //   ],
              //   bottomNavigationBar: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       IconButton(
              //         onPressed: controller.handleTapZoomOut,
              //         icon: const Icon(Icons.zoom_out),
              //       ),
              //       IconButton(
              //         onPressed: controller.undoPage,
              //         icon: const Icon(Icons.undo_rounded),
              //       ),
              //       IconButton(
              //         onPressed: controller.handleTapPreviousPage,
              //         icon: const Icon(Icons.navigate_before),
              //       ),
              //       ActionChip(
              //         label: Obx(() => Text(
              //             "${controller.currentPage.value + 1}/${controller.totalPages}")),
              //         onPressed: () {
              //           Get.dialog(AlertDialog(
              //             title: const Text('Go to Page'),
              //             content: TextFormField(
              //               initialValue: '${controller.currentPage.value + 1}',
              //               autovalidateMode: AutovalidateMode.onUserInteraction,
              //               decoration: const InputDecoration(
              //                 labelText: 'Enter page numbber',
              //               ),
              //               inputFormatters: <TextInputFormatter>[
              //                 FilteringTextInputFormatter.digitsOnly,
              //               ],
              //               onChanged: (text) {
              //                 controller.gotopage = int.tryParse(text);
              //               },
              //               validator: (text) {
              //                 if (text == null || text.isEmpty) {
              //                   return 'Can\'t be empty';
              //                 }

              //                 if (controller.gotopage == null) {
              //                   return '"$text" is not a valid page number';
              //                 } else {
              //                   if (controller.gotopage! >=
              //                           controller.totalPages.value ||
              //                       controller.gotopage! <= 0) {
              //                     return 'Page Not Exist';
              //                   }
              //                 }
              //                 return null;
              //               },
              //               autofocus: true,
              //               keyboardType: TextInputType.number,
              //             ),
              //             backgroundColor:
              //                 Get.isDarkMode ? Colors.black : Colors.white,
              //             actions: [
              //               OutlinedButton(
              //                   onPressed: () => Get.back(),
              //                   child: const Text('Back')),
              //               OutlinedButton(
              //                   onPressed: () {
              //                     if (controller.gotopage != null &&
              //                             (controller.gotopage! <
              //                                 controller.totalPages.value) ||
              //                         controller.gotopage! >= 0) {
              //                       Get.back();
              //                       controller.goToPage(controller.gotopage! - 1);
              //                     }
              //                   },
              //                   child: const Text('Go'))
              //             ],
              //           ));
              //         },
              //       ),
              //       IconButton(
              //         onPressed: controller.handleTapNextPage,
              //         icon: const Icon(Icons.navigate_next),
              //       ),
              //       IconButton(
              //         onPressed: controller.redoPage,
              //         icon: const Icon(Icons.redo_rounded),
              //       ),
              //       IconButton(
              //         onPressed: controller.handleTappZoomIn,
              //         icon: const Icon(Icons.zoom_in),
              //       ),
              //     ],
              //   ),
              //   // bottomNavigationBar:
              //   //     Obx(() => controller.isBottomBannerAdLoaded.isTrue
              //   //         ? SizedBox(
              //   //             height: 50,
              //   //             width: 320,
              //   //             child:
              //   //                 controller.adWidget(ad: controller.bottomBannerAd),
              //   //           )
              //   //         : SizedBox(
              //   //             height: 50,
              //   //             width: 320,
              //   //             child: Text(
              //   //               controller.filePath.split('/').last,
              //   //               textAlign: TextAlign.center,
              //   //               softWrap: true,
              //   //             ),
              //   //           )),
              //   //top: false,
              //   body: Obx(
              //     () => controller.isDecryptionDone.isFalse
              //         ? Center(
              //             child: Lottie.asset(
              //               'assets/loading.json',
              //               fit: BoxFit.fill,
              //             ),
              //           )
              //         : AlhPdfView(
              //             key: GlobalKey(),
              //             filePath: controller.fileOut,
              //             // pdfData: File(controller.fileOut).readAsBytesSync(),
              //             enableSwipe: true,
              //             swipeHorizontal: controller.swipehorizontal.value,
              //             autoSpacing: false,
              //             pageFling: false,
              //             pageSnap: false,
              //             nightMode: controller.changeTheme.value,
              //             fitEachPage: true,
              //             fitPolicy: FitPolicy.both,
              //             defaultPage: controller.intialPageNumber,
              //             minZoom: 1,
              //             maxZoom: 5,
              //             enableDefaultScrollHandle: false,
              //             onRender: (pages) {
              //               controller.totalPages.value = pages;
              //             },
              //             onError: (error) {
              //               Get.dialog(
              //                 AlertDialog(
              //                   alignment: Alignment.center,
              //                   backgroundColor:
              //                       Get.isDarkMode ? Colors.black : Colors.white,
              //                   title: const Icon(Icons.error_outline),
              //                   content: Text(
              //                     error,
              //                     textAlign: TextAlign.center,
              //                     style: const TextStyle(
              //                       fontWeight: FontWeight.w800,
              //                       fontSize: 20,
              //                     ),
              //                   ),
              //                   actions: <Widget>[
              //                     TextButton(
              //                       onPressed: () async {
              //                         if (Get.isOverlaysOpen) {
              //                           Get.back(
              //                               closeOverlays: true, canPop: true);
              //                         }
              //                       },
              //                       child: const Text('OK'),
              //                     ),
              //                   ],
              //                 ),
              //                 barrierDismissible: false,
              //               );
              //             },
              //             onPageError: (page, error) {
              //               Get.showSnackbar(GetSnackBar(
              //                 backgroundColor:
              //                     Get.theme.snackBarTheme.backgroundColor!,
              //                 messageText: Text(
              //                     'The Page $page has an error : ${error.toString()}'),
              //                 icon: const Icon(Icons.error_outline),
              //                 snackPosition: SnackPosition.TOP,
              //                 duration: const Duration(seconds: 3),
              //               ));
              //             },
              //             onViewCreated:
              //                 (AlhPdfViewController pdfViewController) {
              //               // controller.pdfController.complete(pdfViewController);
              //               controller.pdfViewController = pdfViewController;
              //             },

              //             onPageChanged: (int? page, int? total) {
              //               if (page != null && total != null) {
              //                 controller.intialPageNumber = page;
              //                 controller.currentPage.value = page;
              //                 controller.pageTimer = 0;
              //                 //  controller.lastChanged = controller.pageTimer;
              //               }

              //               ///  print('page change: /');
              //             },
              //           ),
              //   ),
              // ),
            ]),
          )
        : const NoInternetView());
  }
}
