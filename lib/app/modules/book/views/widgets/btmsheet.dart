import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

import '../../controllers/book_controller.dart';
import 'liquidcustomindicator.dart';

class DownloadBtmSheet extends StatelessWidget {
  const DownloadBtmSheet({
    Key? key,
    required this.controller,
    required this.filePath,
    required this.index,
  }) : super(key: key);

  final BookController controller;
  final String filePath;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: Get.isDarkMode ? Colors.black : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LiquidCustomProgressIndicator(
                value: controller.received.value / controller.total.value,
                direction: Axis.vertical,
                backgroundColor: Colors.amber,
                valueColor: const AlwaysStoppedAnimation(Colors.red),
                shapePath: _buildHeartPath(),
                center: Text(
                  '${(controller.received.value / controller.total.value * 100).toStringAsFixed(0)} %',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Get.back(), child: const Text('Back')),
                  TextButton.icon(
                    onPressed: () async {
                      await controller.downloadFile(filePath);
                    },
                    icon: const Icon(Icons.file_download),
                    label: Text((controller.received.value / 1048576)
                            .toStringAsFixed(1) +
                        '/' +
                        (controller.total.value / 1048576).toStringAsFixed(1) +
                        ' MB'),
                  ),
                  File(filePath).existsSync()
                      ? TextButton.icon(
                          onPressed: () {
                            Get.back();
                            Get.toNamed(
                              Routes.viewPdf,
                              arguments: [filePath, true],
                            );
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Open File'),
                        )
                      : const SizedBox(
                          height: 0,
                          width: 0,
                        ),
                ],
              ),
            ],
          ),
        ));
  }
}

Path _buildHeartPath() {
  return Path()
    ..moveTo(55, 15)
    ..cubicTo(55, 12, 50, 0, 30, 0)
    ..cubicTo(0, 0, 0, 37.5, 0, 37.5)
    ..cubicTo(0, 55, 20, 77, 55, 95)
    ..cubicTo(90, 77, 110, 55, 110, 37.5)
    ..cubicTo(110, 37.5, 110, 0, 80, 0)
    ..cubicTo(65, 0, 55, 12, 55, 15)
    ..close();
}
