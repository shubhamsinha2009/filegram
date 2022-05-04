import 'package:collection/collection.dart';
import '../../../data/enums/docpermission.dart';
import '../../../data/model/documents_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../controllers/encrypted_file_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentPermissionBottomSheet extends StatelessWidget {
  const DocumentPermissionBottomSheet({
    Key? key,
    required DocumentModel document,
    required EncryptedFileListController controller,
  })  : _document = document,
        _controller = controller,
        super(key: key);

  final DocumentModel _document;
  final EncryptedFileListController _controller;

  @override
  Widget build(BuildContext context) {
    _controller.groupValue.value = _document.documentPermission;
    if (_document.sharedEmailIds != null) {
      _controller.sharedEmailIds.assignAll(_document.sharedEmailIds!);
    }

    return Obx(() => AnimatedContainer(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          duration: const Duration(milliseconds: 500),
          child: Wrap(
            children: [
              const Text(
                'Document Permission',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RadioListTile<DocumentPermission>(
                title: const Text('Private'),
                value: DocumentPermission.private,
                groupValue: _controller.groupValue.value,
                onChanged: (DocumentPermission? value) {
                  if (value != null) {
                    _controller.groupValue.value = value;
                  }
                },
              ),
              RadioListTile<DocumentPermission>(
                title: const Text('Public'),
                value: DocumentPermission.public,
                groupValue: _controller.groupValue.value,
                onChanged: (DocumentPermission? value) {
                  if (value != null) {
                    _controller.groupValue.value = value;
                  }
                },
              ),
              RadioListTile<DocumentPermission>(
                title: const Text('Shared'),
                value: DocumentPermission.shared,
                groupValue: _controller.groupValue.value,
                onChanged: (DocumentPermission? value) {
                  if (value != null) {
                    _controller.groupValue.value = value;
                  }
                },
              ),
              _controller.groupValue.value == DocumentPermission.shared
                  ? ListView.builder(
                      itemCount: _controller.sharedEmailIds.length,
                      padding: const EdgeInsets.only(bottom: 10),
                      shrinkWrap: true,
                      itemBuilder: (context, index) => ListTile(
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          enabled: true,
                          horizontalTitleGap: 0,
                          trailing: index != 0
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _controller.sharedEmailIds
                                      .removeAt(index),
                                )
                              : null,
                          dense: true,
                          title: Text(
                            _controller.sharedEmailIds[index],
                          )),
                    )
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
              _controller.groupValue.value == DocumentPermission.shared
                  ? TextFormField(
                      autofocus: true,
                      controller: _controller.textEditingController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              _controller.textEditingController.clear(),
                        ),
                        // floatingLabelBehavior: FloatingLabelBehavior.always,
                        // labelText: 'Add people to share with ',
                        border: const OutlineInputBorder(),
                        hintText: 'Enter Email Id',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      keyboardAppearance: Brightness.dark,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (GetUtils.isEmail(value)) {
                            return null;
                          } else {
                            return "Email Id is not valid";
                          }
                        }
                        return null;
                      },
                      maxLines: 1,
                    )
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
              const SizedBox(
                height: 10,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      _controller.sharedEmailIds.clear();
                      Get.back(closeOverlays: true);
                    },
                    child: const Text('Back'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Get.dialog(AlertDialog(
                        title: const Text('Rewarded Feature'),
                        content: const Text(
                            'Please watch full rewarded ad to save and change your document permission'),
                        actions: [
                          OutlinedButton(
                              onPressed: () => Get.back(),
                              child: const Text('Back')),
                          OutlinedButton(
                              onPressed: () {
                                _controller.rewardedInterstitialAd.show(
                                    onUserEarnedReward: (ad, reward) async {
                                  const _isList =
                                      DeepCollectionEquality.unordered();
                                  if (DocumentPermission.values.byName(_document
                                              .documentPermission.name) !=
                                          _controller.groupValue.value ||
                                      !_isList.equals(
                                          _controller.sharedEmailIds,
                                          _document.sharedEmailIds)) {
                                    await FirestoreData
                                        .updateDocumentPermission(
                                            documentId: _document.documentId,
                                            documentPermission:
                                                _controller.groupValue.value,
                                            emailIds:
                                                _controller.sharedEmailIds);
                                    await FirestoreData.getDocumentAfterUpdate(
                                        _document.documentId);
                                    _controller.documents.clear();

                                    await _controller.findAllEncryptedFiles();
                                    _controller.sharedEmailIds.clear();

                                    Get.back(closeOverlays: true);
                                  }
                                });
                              },
                              child: const Text('Save'))
                        ],
                        backgroundColor: Colors.black,
                      ));
                    },
                    child: const Text('Save'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      if (_controller.textEditingController.text.isNotEmpty &&
                          _controller.textEditingController.text.isEmail) {
                        _controller.sharedEmailIds
                            .add(_controller.textEditingController.text);
                        _controller.textEditingController.clear();
                      }
                    },
                    child: const Text('Done'),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
