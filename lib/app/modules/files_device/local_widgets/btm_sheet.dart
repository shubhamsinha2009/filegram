import 'package:filegram/app/modules/files_device/controllers/files_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BtmSheet extends StatelessWidget {
  const BtmSheet({
    Key? key,
    required this.controller,
    required this.filePath,
  }) : super(key: key);

  final FilesDeviceController controller;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
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
            initialValue: controller.nameOfFile(filePath),
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
                          .changeFileNameOnlySync(filePath)
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
