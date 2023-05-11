import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/provider/firestore_data.dart';
import '../encrypted_file_list.dart';
import '../localwidgets/document_bottom_sheet.dart';
import 'package:lottie/lottie.dart';
import 'package:filegram/app/core/extensions.dart';
import '../../../data/model/documents_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypted_file_list_controller.dart';

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
                            width: controller.inlineBannerAd?.size.width
                                .toDouble(),
                            height: controller.inlineBannerAd?.size.height
                                .toDouble(),
                            child: controller.adWidget(
                                ad: controller.inlineBannerAd!),
                          );
                        } else {
                          final DocumentModel? document =
                              state?[controller.getListViewItemIndex(index)];

                          return Slidable(
                            key: UniqueKey(),
                            startActionPane: ActionPane(
                              dismissible: DismissiblePane(
                                  motion: const BehindMotion(),
                                  dismissThreshold: 0.9,
                                  closeOnCancel: true,
                                  confirmDismiss: () async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Get.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          title: Text(
                                            '"Are you sure you wish to delete this file ${document?.documentName?.removeExtension} forever from servers?',
                                          ),
                                          content: const Text(
                                              'After you delete your file, Nobody will be able to decrypt this file ever'),
                                          actions: <Widget>[
                                            OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text("DELETE")),
                                            OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: () {
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
                                    controller
                                        .showInterstitialAd()
                                        .catchError((e) {});
                                    if (Get.isOverlaysOpen) {
                                      Get.back(closeOverlays: true);
                                    }
                                    // ! Sometimes due to async document gets deleted before views
                                    FirestoreData.deleteViewsAndUploads(
                                            document?.documentId)
                                        .then((value) =>
                                            FirestoreData.deleteDocument(
                                                    documentId:
                                                        document?.documentId)
                                                .then((value) {
                                              controller.documents.clear();
                                              controller.getFirstData = false;
                                              controller
                                                  .findAllEncryptedFiles();

                                              Get.showSnackbar(GetSnackBar(
                                                backgroundColor: Get
                                                    .theme
                                                    .snackBarTheme
                                                    .backgroundColor!,
                                                messageText: Text(
                                                    'The File ${document?.documentName} is deleted from server'),
                                                icon: const Icon(Icons
                                                    .delete_forever_rounded),
                                                snackPosition:
                                                    SnackPosition.TOP,
                                                duration:
                                                    const Duration(seconds: 3),
                                              ));
                                            }));
                                    //   });
                                    //         },
                                    //         child:
                                    //             const Text('Delete'))
                                    //   ],
                                    //   backgroundColor: Colors.black,
                                    // ));
                                  }),
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    controller
                                        .showInterstitialAd()
                                        .catchError((e) {});
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
                                    final views =
                                        await FirestoreData.readViewsAndUploads(
                                            document?.documentId);
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
                                          'Number of Views : ${views.views} \n \n & \n \n  Number of Uploads : ${views.numberOfUploads} ',
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
                                  },
                                  // });
                                  //         },
                                  //         child: const Text('OK'))
                                  //   ],
                                  //   backgroundColor: Colors.black,
                                  // ));,
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.black,
                                  icon: Icons.remove_red_eye_outlined,
                                  autoClose: true,
                                  label: 'Views',
                                  spacing: 10,
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              dismissible: DismissiblePane(
                                  motion: const BehindMotion(),
                                  dismissThreshold: 0.9,
                                  closeOnCancel: true,
                                  confirmDismiss: () async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Get.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          title: Text(
                                            '"Are you sure you wish to delete this file ${document?.documentName?.removeExtension} forever from servers?',
                                          ),
                                          content: const Text(
                                              'After you delete your file, Nobody will be able to decrypt this file ever'),
                                          actions: <Widget>[
                                            OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text("DELETE")),
                                            OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: () {
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
                                    controller
                                        .showInterstitialAd()
                                        .catchError((e) {});
                                    if (Get.isOverlaysOpen) {
                                      Get.back(closeOverlays: true);
                                    }
                                    // ! Sometimes due to async document gets deleted before views
                                    FirestoreData.deleteViewsAndUploads(
                                            document?.documentId)
                                        .then((value) =>
                                            FirestoreData.deleteDocument(
                                                    documentId:
                                                        document?.documentId)
                                                .then((value) {
                                              controller.documents.clear();
                                              controller.getFirstData = false;
                                              controller
                                                  .findAllEncryptedFiles();

                                              Get.showSnackbar(GetSnackBar(
                                                backgroundColor: Get
                                                    .theme
                                                    .snackBarTheme
                                                    .backgroundColor!,
                                                messageText: Text(
                                                    'The File ${document?.documentName} is deleted from server'),
                                                icon: const Icon(Icons
                                                    .delete_forever_rounded),
                                                snackPosition:
                                                    SnackPosition.TOP,
                                                duration:
                                                    const Duration(seconds: 3),
                                              ));
                                            }));
                                    //   });
                                    //         },
                                    //         child:
                                    //             const Text('Delete'))
                                    //   ],
                                    //   backgroundColor: Colors.black,
                                    // ));
                                  }),
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) =>
                                      Get.bottomSheet(Container(
                                    color: Get.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.all(16),
                                    child: Wrap(
                                      children: <Widget>[
                                        const Text(
                                          'Shared Link // Source Url',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          keyboardType: TextInputType.url,
                                          onChanged: (value) =>
                                              controller.sourceUrl = value,
                                          initialValue: document?.sourceUrl,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              helperText:
                                                  'This Url feature helps users to identify the source of the file  i.e. From where the file was originated.',
                                              labelText:
                                                  'Source URL / Share Link to redirect',
                                              hintText:
                                                  'https://t.me/filegram_app',
                                              helperMaxLines: 3,
                                              isDense: true,
                                              prefixIcon:
                                                  Icon(Icons.add_link_rounded),
                                              prefixIconColor: Colors.white54),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        ButtonBar(
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                if (Get.isOverlaysOpen) {
                                                  Get.back();
                                                }
                                                Get.showSnackbar(
                                                  GetSnackBar(
                                                    backgroundColor: Get
                                                        .theme
                                                        .snackBarTheme
                                                        .backgroundColor!,
                                                    message: 'Cancelled',
                                                    // backgroundColor: Colors.amber,
                                                    duration: const Duration(
                                                        seconds: 3),
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                  ),
                                                );
                                              },
                                              child: const Text('Cancel'),
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
                                                if (Get.isOverlaysOpen) {
                                                  Get.back();
                                                }
                                                controller
                                                    .showInterstitialAd()
                                                    .catchError((e) {});
                                                // await interstitialAdController
                                                //     .showInterstitialAd();

                                                try {
                                                  FirestoreData.setSourceUrl(
                                                          documentId: document
                                                              ?.documentId,
                                                          sourceUrl: controller
                                                              .sourceUrl)
                                                      .then((value) =>
                                                          Get.showSnackbar(
                                                            GetSnackBar(
                                                              backgroundColor: Get
                                                                  .theme
                                                                  .snackBarTheme
                                                                  .backgroundColor!,
                                                              message:
                                                                  'Link Changed',
                                                              // backgroundColor: Colors.amber,
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          3),
                                                              snackPosition:
                                                                  SnackPosition
                                                                      .TOP,
                                                            ),
                                                          ));
                                                } on Exception catch (e) {
                                                  Get.showSnackbar(
                                                    GetSnackBar(
                                                      backgroundColor: Get
                                                          .theme
                                                          .snackBarTheme
                                                          .backgroundColor!,
                                                      message: e.toString(),
                                                      // backgroundColor: Colors.amber,
                                                      duration: const Duration(
                                                          seconds: 3),
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
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.black,
                                  icon: Icons.link,
                                  autoClose: true,
                                  label: 'Link',
                                  spacing: 10,
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    Get.bottomSheet(
                                      DocumentPermissionBottomSheet(
                                        document: document!,
                                        controller: controller,
                                      ),
                                      backgroundColor: Get.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                      isDismissible: true,
                                      isScrollControlled: true,
                                    );
                                  },
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.black,
                                  icon: Icons.folder_shared_outlined,
                                  autoClose: true,
                                  spacing: 10,
                                  label:
                                      '${document?.documentPermission.name.capitalize}',
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                '${document?.documentName?.removeExtension}',
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                              subtitle: Text(
                                controller.getSubtitle(
                                    bytes: document?.documentSize,
                                    time:
                                        document?.createdOn ?? DateTime.now()),
                                maxLines: 1,
                                softWrap: true,
                              ),
                              visualDensity:
                                  VisualDensity.adaptivePlatformDensity,
                            ),
                          );
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
