import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';

import '../../../data/enums/docpermission.dart';
import '../../../data/model/documents_model.dart';
import '../../encrypted_file_list/controllers/controllers.dart';

class DocpermissionController extends GetxController {
  final docController = Get.find<EncryptedFileListController>();
  DocumentModel document = Get.arguments;
  final TextEditingController textEditingController = TextEditingController();
  final sharedEmailIds = <String>[].obs;
  final groupValue = DocumentPermission.public.obs;

  Future<void> pickFile() async {
    final result = await FlutterFileDialog.pickFile(
        params: const OpenFileDialogParams(
      mimeTypesFilter: [
        'text/plain',
        'text/tab-separated-values',
      ],
    ));

    if (result != null) {
      String contents = await File(result).readAsString();
      Set<String> uniqueIds = Set<String>.from(sharedEmailIds);
      uniqueIds.addAll(contents.split('\n'));
      sharedEmailIds.assignAll(uniqueIds);
    } else {
      // User canceled the file picking.
    }
  }

  @override
  void onClose() {
    textEditingController.clear();
    textEditingController.dispose();
    super.onClose();
  }
}
