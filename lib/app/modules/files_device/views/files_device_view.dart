import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filegram/app/core/services/getstorage.dart';
import 'package:filegram/app/modules/files_device/local_widgets/btm_sheet.dart';
import 'package:filegram/app/modules/homebannerad/controllers/homebannerad_controller.dart';
import 'package:filegram/app/modules/homebannerad/views/homebannerad_view.dart';
import 'package:filegram/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/files_device_controller.dart';

class FilesDeviceView extends GetView<FilesDeviceController> {
  const FilesDeviceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          backgroundColor: Colors.white,
          color: Colors.black87,
          strokeWidth: 4,
          displacement: 150,
          edgeOffset: 0,
          onRefresh: () async {
            controller.onInitialisation();
            Get.reload<HomeBannerAdController>();
          },
          child: ListView.builder(
            itemCount: controller.filesList.length +
                (controller.adsController.isInlineBannerAdLoaded.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (controller.adsController.isInlineBannerAdLoaded.value &&
                  index == (controller.inlineAdIndex) &&
                  controller.filesList.length >= controller.inlineAdIndex) {
                return const HomeBannerAdView();
              } else {
                final _currentfile = controller
                    .filesList[controller.getListViewItemIndex(index)];
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
                        controller.doDecryption(_currentfile.path).then(
                            (value) => value == true
                                ? Get.toNamed(Routes.viewPdf,
                                    arguments: controller.fileOut)
                                : null);
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
              }
            },
          ),
        ));
  }
}
