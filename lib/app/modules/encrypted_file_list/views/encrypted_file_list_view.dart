import 'package:filegram/app/data/provider/firestore_data.dart';
import 'package:filegram/app/modules/encrypted_file_list/encrypted_file_list.dart';
import 'package:filegram/app/modules/encrypted_file_list/localwidgets/document_bottom_sheet.dart';
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
    return controller.obx(
      (state) => RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        backgroundColor: Colors.white,
        color: Colors.black87,
        strokeWidth: 4,
        displacement: 150,
        edgeOffset: 0,
        onRefresh: () async {
          controller.documents.clear();

          await controller.findAllEncryptedFiles();
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.scroll,
          itemCount: state?.length,
          itemBuilder: (context, index) {
            final DocumentModel _document = state![index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                // textBaseline: TextBaseline.alphabetic,
                // verticalDirection: VerticalDirection.down,
                children: [
                  Text(
                    '${_document.documentName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    DateFormat.yMMMEd()
                        .add_jms()
                        .format(_document.createdOn ?? DateTime.now()),
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    '${_document.documentSize}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Get.bottomSheet(
                          DocumentPermissionBottomSheet(
                            document: _document,
                            controller: controller,
                          ),
                          backgroundColor: Colors.black,
                          isDismissible: true,
                          isScrollControlled: true,
                        ),
                        child: Text(
                            '${_document.documentPermission.name.capitalize}'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final _views = await FirestoreData.readViews(
                              _document.documentId);
                          Get.dialog(
                            AlertDialog(
                              alignment: Alignment.center,
                              backgroundColor: Colors.black,
                              title: const Text(
                                ' Number of Views',
                              ),
                              content: Text(
                                _views.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 50,
                                  letterSpacing: 1,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
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
                        child: const Text('Views'),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.black,
                            title: Text(
                              ' ${_document.documentName} will be deleted?',
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
                                onPressed: () async {
                                  await FirestoreData.deleteDocument(
                                      documentId: _document.documentId);
                                  controller.documents.clear();

                                  await controller.findAllEncryptedFiles();
                                  if (Get.isOverlaysOpen) {
                                    Get.back();
                                  }
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                          barrierDismissible: false,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black54,
                      Colors.black87,
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
            );
          },
        ),
      ),
      onLoading: const Center(child: CircularProgressIndicator()),
      onEmpty: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
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
              height: 100,
            ),
            Lottie.asset(
              "assets/empty.json",
            ),
            const SizedBox(
              height: 100,
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
              height: 50,
            ),
            TextButton.icon(
              onPressed: () async {
                controller.documents.clear();

                await controller.findAllEncryptedFiles();
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
        ),
      ),
      onError: (error) => Center(
          child: Column(
        children: [
          Lottie.asset('assets/error.json'),
          const SizedBox(
            height: 50,
          ),
          TextButton.icon(
            onPressed: () async {
              controller.documents.clear();

              await controller.findAllEncryptedFiles();
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
    );
  }
}
