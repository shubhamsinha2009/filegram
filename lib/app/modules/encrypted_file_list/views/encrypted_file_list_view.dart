import 'package:filegram/app/data/model/documents_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/encrypted_file_list_controller.dart';

class EncryptedFileListView extends GetView<EncryptedFileListController> {
  const EncryptedFileListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.documents.clear();

        await controller.findAllEncryptedFiles();
      },
      child: controller.obx(
        (state) => ListView.builder(
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

        //TODO : Shimmer Effect
        onLoading: const Center(child: LinearProgressIndicator()),
        onEmpty: const Center(
          child: Text(
            'Repositories no found',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        onError: (error) => Center(
          child: Text(
            'Error: Cannot get repositories \n$error',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
