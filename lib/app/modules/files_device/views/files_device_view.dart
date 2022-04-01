import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:filegram/app/modules/files_device/local_widgets/btm_sheet.dart';
import 'package:filegram/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
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
                    if (_currentfile is File) {
                      return Slidable(
                        startActionPane: ActionPane(
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
                            SlidableAction(
                              onPressed: (context) async {
                                _currentfile.deleteSync();
                                GetStorageDbService.getRemove(
                                    key: _currentfile.path);
                                controller.onInitialisation();
                                // await controller.analytics.logEvent(
                                //     name: 'file_deleted',
                                //     parameters: {'deleted_file': _currentfile.path});
                                Get.snackbar('Done', 'Your File is Deleted');
                              },
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              icon: Icons.delete,
                              autoClose: true,
                              spacing: 10,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  controller.save(_currentfile.path),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.black,
                              icon: Icons.drive_file_rename_outline,
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
                                Share.shareFiles(
                                  [_currentfile.path],
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
                          // trailing: const Icon(
                          //   Icons.picture_as_pdf,
                          //   color: Colors.deepOrange,
                          // ),

                          isThreeLine: true,
                          dense: true,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          title: Text(
                            controller.nameOfFile(_currentfile.path),
                            maxLines: 1,
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
                            controller.interstitialAdController
                                .showInterstitialAd();
                            Get.toNamed(Routes.viewPdf,
                                arguments: _currentfile.path);
                            // await controller.analytics
                            //     .setCurrentScreen(screenName: 'pdf');
                            // await controller.analytics
                            //     .logScreenView(screenName: 'pdf_viewer');
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
                    Lottie.asset(
                      "assets/empty.json",
                      height: 250,
                      width: double.infinity,
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
