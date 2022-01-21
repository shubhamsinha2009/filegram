import 'package:lottie/lottie.dart';

import '../../../data/model/documents_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypted_file_list_controller.dart';

class EncryptedFileListView extends GetView<EncryptedFileListController> {
  const EncryptedFileListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => RefreshIndicator(
        onRefresh: () async {
          controller.documents.clear();

          await controller.findAllEncryptedFiles();
        },
        child: ListView.builder(
          controller: controller.scroll,
          itemCount: state?.length,
          itemBuilder: (context, index) {
            final DocumentModel _document = state![index];
            return ListTile(
              isThreeLine: true,
              leading: Text(
                (++index).toString(),
                style: const TextStyle(fontSize: 20),
              ),
              title: Text(_document.documentName ?? ''),
              subtitle: Text(_document.documentSize ?? ''),
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
                color: Colors.amber,
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
          ],
        ),
      ),
      onError: (error) => Center(child: Lottie.asset('assets/error.json')),
    );
  }
}
