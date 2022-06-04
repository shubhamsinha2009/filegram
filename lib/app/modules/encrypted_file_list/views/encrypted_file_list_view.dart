import '../../../data/provider/firestore_data.dart';
import '../encrypted_file_list.dart';
import '../localwidgets/document_bottom_sheet.dart';
import 'package:lottie/lottie.dart';

import '../../../data/model/documents_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypted_file_list_controller.dart';
import 'package:intl/intl.dart';

class EncryptedFileListView extends GetView<EncryptedFileListController> {
  const EncryptedFileListView({Key? key}) : super(key: key);

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
          controller.getFirstData = false;
          controller.documents.clear();
          controller.findAllEncryptedFiles();
        },
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLines: 1,
              onChanged: (value) => controller.filterfileList(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search By File Name',
                isDense: true,
              ),
            ),
          ),
          Expanded(
              child: controller.obx(
                  (state) => ListView.builder(
                      addAutomaticKeepAlives: true,
                      itemCount: (state?.length)! +
                          (controller.isInlineBannerAdLoaded.isTrue &&
                                  ((state?.length)! >= controller.inlineAdIndex)
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (controller.isInlineBannerAdLoaded.isTrue &&
                            index == controller.inlineAdIndex &&
                            ((state?.length)! >= controller.inlineAdIndex)) {
                          return Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            width:
                                controller.inlineBannerAd.size.width.toDouble(),
                            height: controller.inlineBannerAd.size.height
                                .toDouble(),
                            child: controller.adWidget(
                                ad: controller.inlineBannerAd),
                          );
                        } else {
                          final DocumentModel? _document =
                              state?[controller.getListViewItemIndex(index)];

                          return Obx(() => AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                padding: const EdgeInsets.only(
                                  top: 15,
                                  bottom: 0,
                                  left: 15,
                                  right: 15,
                                ),
                                margin: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  // textBaseline: TextBaseline.alphabetic,
                                  // verticalDirection: VerticalDirection.down,
                                  children: [
                                    Text(
                                      '${_document?.documentName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      DateFormat.yMMMEd().add_jms().format(
                                          _document?.createdOn ??
                                              DateTime.now()),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      '${_document?.documentSize}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        OutlinedButton(
                                          // onPressed: () => controller
                                          //     .adsController.rewardedAd
                                          //     .show(onUserEarnedReward: (ad, reward) {
                                          onPressed: () => Get.bottomSheet(
                                            DocumentPermissionBottomSheet(
                                              document: _document!,
                                              controller: controller,
                                            ),
                                            backgroundColor: Get.isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                            isDismissible: true,
                                            isScrollControlled: true,
                                          ),
                                          // }),
                                          child: Text(
                                              '${_document?.documentPermission.name.capitalize}'),
                                        ),
                                        OutlinedButton(
                                          onPressed: () async {
                                            // Get.dialog(AlertDialog(
                                            //   title: const Text('Rewarded Feature'),
                                            //   content: const Text(
                                            //       'Please watch full rewarded ad to see number of views and uploads '),
                                            //   actions: [
                                            //     OutlinedButton(
                                            //         onPressed: () => Get.back(),
                                            //         child: const Text('Back')),
                                            //     OutlinedButton(
                                            //         onPressed: () {
                                            //           controller
                                            //               .rewardedInterstitialAd
                                            //               .show(onUserEarnedReward:
                                            //                   (ad, reward) async {
                                            final _views = await FirestoreData
                                                .readViewsAndUploads(
                                                    _document?.documentId);
                                            // controller.adsController.rewardedAd.show(
                                            //   onUserEarnedReward: (ad, reward) {
                                            Get.dialog(
                                              AlertDialog(
                                                alignment: Alignment.center,
                                                backgroundColor: Get.isDarkMode
                                                    ? Colors.black
                                                    : Colors.white,
                                                // title: const Text(
                                                //   ' Number of Views',
                                                // ),
                                                content: Text(
                                                  'Number of Views : ${_views.views} \n \n & \n \n  Number of Uploads : ${_views.numberOfUploads} ',
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
                                                        Get.back();
                                                      }
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                              barrierDismissible: false,
                                            );
                                            // });
                                            //         },
                                            //         child: const Text('OK'))
                                            //   ],
                                            //   backgroundColor: Colors.black,
                                            // ));
                                          },
                                          //  );
                                          // },
                                          child: const Text('Views'),
                                        ),
                                        OutlinedButton(
                                          // onPressed: () => controller
                                          //     .adsController.rewardedAd
                                          //     .show(onUserEarnedReward: (ad, reward) {
                                          onPressed: () => Get.dialog(
                                            AlertDialog(
                                              backgroundColor: Get.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white,
                                              title: Text(
                                                '"Are you sure you wish to delete this file ${_document?.documentName} forever from servers?',
                                              ),
                                              content: const Text(
                                                  'After you delete your file, Nobody will be able to decrypt this file ever'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    if (Get.isOverlaysOpen) {
                                                      Get.back();
                                                    }
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Get.dialog(AlertDialog(
                                                    //   title: const Text(
                                                    //       'Rewarded Feature'),
                                                    //   content: const Text(
                                                    //       'Please watch full rewarded ad to delete '),
                                                    //   actions: [
                                                    //     OutlinedButton(
                                                    //         onPressed: () =>
                                                    //             Get.back(),
                                                    //         child:
                                                    //             const Text('Back')),
                                                    //     OutlinedButton(
                                                    //         onPressed: () {
                                                    //           controller
                                                    //               .rewardedInterstitialAd
                                                    //               .show(
                                                    //                   onUserEarnedReward:
                                                    //                       (ad,
                                                    //                           reward) {
                                                    if (Get.isOverlaysOpen) {
                                                      Get.back(
                                                          closeOverlays: true);
                                                    }
                                                    // ! Sometimes due to async document gets deleted before views
                                                    FirestoreData
                                                            .deleteViewsAndUploads(
                                                                _document
                                                                    ?.documentId)
                                                        .then((value) =>
                                                            FirestoreData.deleteDocument(
                                                                    documentId:
                                                                        _document
                                                                            ?.documentId)
                                                                .then((value) {
                                                              controller
                                                                  .documents
                                                                  .clear();
                                                              controller
                                                                      .getFirstData =
                                                                  false;
                                                              controller
                                                                  .findAllEncryptedFiles();

                                                              Get.showSnackbar(
                                                                  GetSnackBar(
                                                                backgroundColor: Get
                                                                    .theme
                                                                    .snackBarTheme
                                                                    .backgroundColor!,
                                                                messageText: Text(
                                                                    'The File ${_document?.documentName} is deleted from server'),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .delete_forever_rounded),
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .TOP,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            3),
                                                              ));
                                                            }));
                                                    //   });
                                                    //         },
                                                    //         child:
                                                    //             const Text('Delete'))
                                                    //   ],
                                                    //   backgroundColor: Colors.black,
                                                    // ));
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                            barrierDismissible: false,
                                          ),

                                          child: const Text('Delete'),
                                        ),
                                        OutlinedButton(
                                            onPressed:
                                                () => Get.bottomSheet(Container(
                                                      color: Get.isDarkMode
                                                          ? Colors.black
                                                          : Colors.white,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              16),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Wrap(
                                                        children: <Widget>[
                                                          const Text(
                                                            'Shared Link // Source Url',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                          ),
                                                          const SizedBox(
                                                            height: 50,
                                                          ),
                                                          TextFormField(
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            keyboardType:
                                                                TextInputType
                                                                    .url,
                                                            onChanged: (value) =>
                                                                controller
                                                                        .sourceUrl =
                                                                    value,
                                                            initialValue:
                                                                _document
                                                                    ?.sourceUrl,
                                                            decoration: const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                helperText:
                                                                    'This Url feature helps users to identify the source of the file  i.e. From where the file was originated.',
                                                                labelText:
                                                                    'Source URL / Share Link to redirect',
                                                                hintText:
                                                                    'https://t.me/filegram_app',
                                                                helperMaxLines:
                                                                    3,
                                                                isDense: true,
                                                                prefixIcon:
                                                                    Icon(Icons
                                                                        .add_link_rounded),
                                                                prefixIconColor:
                                                                    Colors
                                                                        .white54),
                                                          ),
                                                          const SizedBox(
                                                            height: 30,
                                                          ),
                                                          ButtonBar(
                                                            children: [
                                                              OutlinedButton(
                                                                onPressed: () {
                                                                  if (Get
                                                                      .isOverlaysOpen) {
                                                                    Get.back();
                                                                  }
                                                                  Get.showSnackbar(
                                                                    GetSnackBar(
                                                                      backgroundColor: Get
                                                                          .theme
                                                                          .snackBarTheme
                                                                          .backgroundColor!,
                                                                      message:
                                                                          'Cancelled',
                                                                      // backgroundColor: Colors.amber,
                                                                      duration: const Duration(
                                                                          seconds:
                                                                              3),
                                                                      snackPosition:
                                                                          SnackPosition
                                                                              .TOP,
                                                                    ),
                                                                  );
                                                                },
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                              OutlinedButton(
                                                                onPressed: () {
                                                                  // Get.dialog(AlertDialog(
                                                                  //   title: const Text(
                                                                  //       'Rewarded Feature'),
                                                                  //   content: const Text(
                                                                  //       'Please watch full rewarded ad to add source link '),
                                                                  //   actions: [
                                                                  //     OutlinedButton(
                                                                  //         onPressed: () =>
                                                                  //             Get.back(),
                                                                  //         child:
                                                                  //             const Text(
                                                                  //                 'Back')),
                                                                  //     OutlinedButton(
                                                                  //         onPressed: () {
                                                                  //           controller
                                                                  //               .rewardedInterstitialAd
                                                                  //               .show(onUserEarnedReward:
                                                                  //                   (ad,
                                                                  //                       reward) {
                                                                  if (Get
                                                                      .isOverlaysOpen) {
                                                                    Get.back();
                                                                  }
                                                                  // await interstitialAdController
                                                                  //     .showInterstitialAd();

                                                                  try {
                                                                    FirestoreData.setSourceUrl(
                                                                            documentId: _document
                                                                                ?.documentId,
                                                                            sourceUrl: controller
                                                                                .sourceUrl)
                                                                        .then((value) =>
                                                                            Get.showSnackbar(
                                                                              GetSnackBar(
                                                                                backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                                                                                message: 'Link Changed',
                                                                                // backgroundColor: Colors.amber,
                                                                                duration: const Duration(seconds: 3),
                                                                                snackPosition: SnackPosition.TOP,
                                                                              ),
                                                                            ));
                                                                  } on Exception catch (e) {
                                                                    Get.showSnackbar(
                                                                      GetSnackBar(
                                                                        backgroundColor: Get
                                                                            .theme
                                                                            .snackBarTheme
                                                                            .backgroundColor!,
                                                                        message:
                                                                            e.toString(),
                                                                        // backgroundColor: Colors.amber,
                                                                        duration:
                                                                            const Duration(seconds: 3),
                                                                        snackPosition:
                                                                            SnackPosition.TOP,
                                                                      ),
                                                                    );
                                                                  }
                                                                  //           });
                                                                  //         },
                                                                  //         child:
                                                                  //             const Text(
                                                                  //                 'OK'))
                                                                  //   ],
                                                                  //   backgroundColor:
                                                                  //       Colors.black,
                                                                  // ));
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Save'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                            child: const Text('Link')),
                                      ],
                                    )
                                  ],
                                ),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        controller.homeController.changeTheme
                                                .isTrue
                                            ? Colors.black54
                                            : Colors.white70,
                                        controller.homeController.changeTheme
                                                .isTrue
                                            ? Colors.black87
                                            : Colors.white,
                                      ],
                                    ),
                                    //color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: controller.homeController
                                                .changeTheme.isTrue
                                            ? Colors.grey.shade900
                                            : Colors.grey.shade400,
                                        offset: const Offset(5, 5),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: controller.homeController
                                                .changeTheme.isTrue
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade300,
                                        offset: const Offset(-4, -4),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      )
                                    ]),
                              ));
                        }
                      }),
                  onLoading: Center(
                      child: Lottie.asset(
                    'assets/loading.json',
                    fit: BoxFit.fill,
                  )),
                  onEmpty: Center(
                      child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "No encrypted Files Found ! ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.fade,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Lottie.asset(
                          "assets/empty.json",
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Start Encrypting Your Files  ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.fade,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          controller.documents.clear();
                          controller.findAllEncryptedFiles();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  )),
                  onError: (error) => Center(
                          child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Lottie.asset('assets/error.json'),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              controller.documents.clear();

                              controller.findAllEncryptedFiles();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Refresh',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ],
                      ))))
        ]));
  }
}
