import 'dart:io';

import 'package:filegram/app/core/extensions.dart';
import 'package:filegram/app/modules/files_device/controllers/files_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BtmSheet extends StatelessWidget {
  const BtmSheet({
    Key? key,
    required this.controller,
    required this.file,
  }) : super(key: key);

  final FilesDeviceController controller;
  final FileSystemEntity file;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.isDarkMode ? Colors.black : Colors.white,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: [
          const Text("Rename"),
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value != null) {
                if (!controller.validateRename()) {
                  return "File Name is not valid";
                } else {
                  return null;
                }
              }
              return null;
            },
            initialValue: file.name,
            keyboardType: TextInputType.name,
            onChanged: (value) => controller.rename.value = value,
            maxLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Get.back(), child: const Text('Back')),
              TextButton(
                  onPressed: () {
                    if (controller.validateRename()) {
                      controller
                          .changeFileNameOnlySync(file.path)
                          .then((value) => Get.back());
                    }
                  },
                  child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }
}
