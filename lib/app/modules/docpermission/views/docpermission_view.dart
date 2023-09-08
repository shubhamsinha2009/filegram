import 'package:collection/collection.dart';
import 'package:filegram/app/core/extensions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../data/enums/docpermission.dart';
import '../../../data/provider/firestore_data.dart';
import '../controllers/docpermission_controller.dart';

class DocpermissionView extends GetView<DocpermissionController> {
  const DocpermissionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.groupValue.value = controller.document.documentPermission;
    if (controller.document.sharedEmailIds != null) {
      controller.sharedEmailIds.assignAll(controller.document.sharedEmailIds!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Permission',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Save'),
        icon: const Icon(Icons.save_rounded),
        onPressed: () async {
          controller.docController.showInterstitialAd().catchError((e) {});
          // Get.dialog(AlertDialog(
          //   title: const Text('Rewarded Feature'),
          //   content: const Text(
          //       'Please watch full rewarded ad to save and change your document permission'),
          //   actions: [
          //     OutlinedButton(
          //         onPressed: () => Get.back(),
          //         child: const Text('Back')),
          //     OutlinedButton(
          //         onPressed: () {
          //           controller.docController.rewardedInterstitialAd.show(
          //               onUserEarnedReward: (ad, reward) async {
          const isList = DeepCollectionEquality.unordered();
          if (DocumentPermission.values
                      .byName(controller.document.documentPermission.name) !=
                  controller.groupValue.value ||
              !isList.equals(controller.sharedEmailIds,
                  controller.document.sharedEmailIds)) {
            await FirestoreData.updateDocumentPermission(
                documentId: controller.document.documentId,
                documentPermission: controller.groupValue.value,
                emailIds: controller.sharedEmailIds);
            await FirestoreData.getDocumentAfterUpdate(
                controller.document.documentId);
            controller.docController.documents.clear();

            controller.docController.findAllEncryptedFiles();
            controller.sharedEmailIds.clear();
            Get.back();
          }
        },
      ),
      body: Obx(() => SingleChildScrollView(
            child: Column(
              children: [
                RadioListTile<DocumentPermission>(
                  title: const Text('Private'),
                  value: DocumentPermission.private,
                  groupValue: controller.groupValue.value,
                  onChanged: (DocumentPermission? value) {
                    if (value != null) {
                      controller.groupValue.value = value;
                    }
                  },
                ),
                RadioListTile<DocumentPermission>(
                  title: const Text('Public'),
                  value: DocumentPermission.public,
                  groupValue: controller.groupValue.value,
                  onChanged: (DocumentPermission? value) {
                    if (value != null) {
                      controller.groupValue.value = value;
                    }
                  },
                ),
                RadioListTile<DocumentPermission>(
                  title: const Text('Shared'),
                  value: DocumentPermission.shared,
                  groupValue: controller.groupValue.value,
                  onChanged: (DocumentPermission? value) {
                    if (value != null) {
                      controller.groupValue.value = value;
                    }
                  },
                ),
                if (controller.groupValue.value == DocumentPermission.shared)
                  TextField(
                    onSubmitted: (value) async {
                      if (controller.textEditingController.text.isNotEmpty) {
                        controller.sharedEmailIds
                            .add(controller.textEditingController.text.gmail);
                        controller.textEditingController.clear();
                      }
                    },
                    controller: controller.textEditingController,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              controller.textEditingController.clear(),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText: 'Add Gmail ID of a person to share  ',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixText: '@gmail.com',
                        suffixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'abc',
                        helperText:
                            "Please dont't write '@gmail.com' again !!!",
                        helperStyle: const TextStyle(color: Colors.red)),
                    keyboardType: TextInputType.emailAddress,
                    keyboardAppearance: Brightness.dark,
                    maxLines: 1,
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (controller.groupValue.value == DocumentPermission.shared)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: controller.pickFile,
                        child: const Text('Upload Emails Tab-Separated File'),
                      ),
                    ],
                  ),
                if (controller.groupValue.value == DocumentPermission.shared)
                  ListView.builder(
                    itemCount: controller.sharedEmailIds.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ListTile(
                        leading: Text('${index + 1}'),
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        enabled: true,
                        horizontalTitleGap: 0,
                        trailing: index != 0
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    controller.sharedEmailIds.removeAt(index),
                              )
                            : null,
                        dense: true,
                        title: Text(
                          controller.sharedEmailIds[index],
                        )),
                  ),
              ],
            ),
          )),
    );
  }
}
