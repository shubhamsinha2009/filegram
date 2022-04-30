import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:filegram/app/modules/files_device/local_widgets/btm_sheet.dart';
import 'package:filegram/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/files_device_controller.dart';

class FilesDeviceView extends GetView<FilesDeviceController> {
  const FilesDeviceView({Key? key}) : super(key: key);

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
          controller.onInitialisation();
        },
        child: Obx(
          () => controller.filesList.isNotEmpty
              ? ListView.builder(
                  itemCount: controller.filesList.length,
                  itemBuilder: (context, index) {
                    final _currentfile = controller.filesList[index];
                    final Map<String, dynamic>? _pdfDetails =
                        GetStorageDbService.getRead(key: _currentfile.path);
                    final _photoUrl = _pdfDetails?['photoUrl'] ??
                        'https://source.unsplash.com/random';
                    final _ownerName = _pdfDetails?['ownerName'] ?? 'Unknown';
                    final _sourceUrl = _pdfDetails?['sourceUrl'];
                    final _ownerId = _pdfDetails?['ownerId'];
                    if (_currentfile is File) {
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
                                    backgroundColor: Colors.black,
                                    title: const Text("Confirm"),
                                    content: const Text(
                                        "Are you sure you wish to delete this file from device"),
                                    actions: <Widget>[
                                      OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("DELETE")),
                                      OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("CANCEL"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: () async {
                              await _currentfile.delete();
                              GetStorageDbService.getRemove(
                                  key: _currentfile.path);
                              controller.onInitialisation();
                              // await controller.analytics.logEvent(
                              //     name: 'file_deleted',
                              //     parameters: {'deleted_file': _currentfile.path});

                              Get.showSnackbar(GetSnackBar(
                                messageText: Text(
                                    'The file ${controller.nameOfFile(_currentfile.path)} is Deleted'),
                                icon: const Icon(Icons.delete_forever_rounded),
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 3),
                              ));
                            },
                          ),
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => Get.bottomSheet(
                                  BtmSheet(
                                    controller: controller,
                                    filePath: _currentfile.path,
                                  ),
                                  isScrollControlled: true),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.black,
                              icon: Icons.drive_file_rename_outline,
                              autoClose: true,
                              label: 'Rename',
                              spacing: 10,
                            ),
                            // TODO: Decrypt
                            // SlidableAction(
                            //   onPressed: (context) =>
                            //       controller.save(_currentfile.path),
                            //   backgroundColor: Colors.orange,
                            //   foregroundColor: Colors.black,
                            //   icon: Icons.save_alt_rounded,
                            //   autoClose: true,
                            //   label: 'Decrypt',
                            //   spacing: 10,
                            // ),
                            // SlidableAction(
                            //   onPressed: (context) {
                            //     _currentfile.deleteSync();
                            //     GetStorageDbService.getRemove(
                            //         key: _currentfile.path);
                            //     controller.onInitialisation();
                            //     // await controller.analytics.logEvent(
                            //     //     name: 'file_deleted',
                            //     //     parameters: {'deleted_file': _currentfile.path});

                            //     Get.showSnackbar(const GetSnackBar(
                            //       messageText: Text('Your File is Deleted'),
                            //       icon: Icon(Icons.delete_forever_rounded),
                            //       snackPosition: SnackPosition.TOP,
                            //       duration: Duration(seconds: 3),
                            //     ));
                            //   },
                            //   backgroundColor: Colors.orange,
                            //   foregroundColor: Colors.black,
                            //   icon: Icons.delete,
                            //   autoClose: true,
                            //   spacing: 10,
                            //   label: 'Delete',
                            // ),
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
                                    backgroundColor: Colors.black,
                                    title: const Text("Confirm"),
                                    content: const Text(
                                        "Are you sure you wish to delete this file from device"),
                                    actions: <Widget>[
                                      OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("DELETE")),
                                      OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("CANCEL"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: () async {
                              await _currentfile.delete();
                              GetStorageDbService.getRemove(
                                  key: _currentfile.path);
                              controller.onInitialisation();
                              // await controller.analytics.logEvent(
                              //     name: 'file_deleted',
                              //     parameters: {'deleted_file': _currentfile.path});

                              Get.showSnackbar(const GetSnackBar(
                                messageText: Text('Your File is Deleted'),
                                icon: Icon(Icons.delete_forever_rounded),
                                snackPosition: SnackPosition.TOP,
                                duration: Duration(seconds: 3),
                              ));
                            },
                          ),
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  controller.save(_currentfile.path),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.black,
                              icon: Icons.download_rounded,
                              autoClose: true,
                              label: 'Save',
                              spacing: 10,
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                // await controller.analytics
                                //     .logEvent(name: 'shared_file', parameters: {
                                //   'file_path': _currentfile.path,
                                // });
                                // TODO: Add text and subject app link and more
                                await Share.shareFiles(
                                  [_currentfile.path],
                                  text:
                                      'Download Filegram to open this file 🔓- https://play.google.com/store/apps/details?id=com.sks.filegram',
                                );
                              },
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              icon: Icons.share,
                              autoClose: true,
                              spacing: 10,
                              label: 'Share',
                            ),
                          ],
                        ),
                        child: ListTile(
                          trailing: _sourceUrl != null
                              ? IconButton(
                                  icon: const Icon(Icons.link_rounded,
                                      color: Colors.white),
                                  onPressed: () async {
                                    try {
                                      await launch(_sourceUrl);
                                    } on PlatformException {
                                      Get.showSnackbar(GetSnackBar(
                                        messageText: Text(
                                            'Cannot Open this link : $_sourceUrl'),
                                        icon: const Icon(Icons.error_outline),
                                        snackPosition: SnackPosition.TOP,
                                        duration: const Duration(seconds: 3),
                                      ));
                                    }
                                  },
                                )
                              : null,
                          isThreeLine: true,
                          dense: true,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          title: Text(
                            controller.nameOfFile(_currentfile.path),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          // selectedTileColor: Theme.of(context).canvasColor,
                          // tileColor: Theme.of(context).canvasColor,
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              _photoUrl,
                            ),
                          ),
                          onTap: () {
                            //try {
                            // controller
                            //     .rewardedAdController.rewardedInterstitialAd
                            //     .show(onUserEarnedReward: (ad, reward) {
                            //   FirestoreData.updateSikka(_ownerId);

                            controller
                                .showInterstitialAd(uid: _ownerId)
                                .catchError((e) {});
                            Get.toNamed(Routes.viewPdf,
                                arguments: _currentfile.path);
                            // });
                            // } catch (e) {
                            //   controller.interstitialAdController
                            //       .showInterstitialAd(uid: _ownerId);
                            //   Get.toNamed(Routes.viewPdf,
                            //       arguments: _currentfile.path);
                            //   // ?.then((value) => controller
                            //   //     .interstitialAdController
                            //   //     .showInterstitialAd());
                            // }
                          },
                          subtitle: Text(
                            _ownerName +
                                '\n' +
                                controller.getSubtitle(
                                  bytes: _currentfile.lengthSync(),
                                  time: _currentfile.lastModifiedSync(),
                                ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(
                        height: 0,
                        width: 0,
                      );
                    }
                  },
                )
              : Center(
                  child: Column(
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
                      onPressed: () async {
                        controller.onInitialisation();
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
        ));
  }
}
