import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/view_pdf_controller.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.controller,
  });

  final ViewPdfController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Obx(
        () => controller.hideAppBar.isFalse
            ? Container(
                color: Colors.black,
                constraints: const BoxConstraints(
                    maxHeight: 300,
                    maxWidth: double.infinity,
                    minWidth: 50,
                    minHeight: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(
                      () => controller.isBottomBannerAdLoaded.isTrue
                          ? SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: controller.adWidget(
                                  ad: controller.bottomBannerAd!),
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            ),
                    ),
                    // PdfScroll(controller: controller),
                    Obx(() => Slider(
                        min: 0.0,
                        max: (controller.totalPages.value - 1).toDouble(),
                        value: controller.currentPage.value.toDouble(),
                        label: '${controller.currentPage.value + 1}',
                        activeColor: Colors.teal,
                        inactiveColor: Colors.blueGrey,
                        divisions: controller.totalPages.value,
                        onChanged: (value) {
                          controller.goToPage(value.toInt());
                        })),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          color: Colors.grey,
                          onPressed: controller.handleTapZoomOut,
                          icon: const Icon(Icons.zoom_out),
                        ),
                        IconButton(
                          color: Colors.grey,
                          onPressed: controller.undoPage,
                          icon: const Icon(Icons.undo_rounded),
                        ),
                        IconButton(
                          color: Colors.grey,
                          onPressed: controller.handleTapPreviousPage,
                          icon: const Icon(Icons.navigate_before),
                        ),
                        ActionChip(
                          backgroundColor: Colors.grey,
                          labelStyle: const TextStyle(color: Colors.black),
                          label: Obx(() => Text(
                              "${controller.currentPage.value + 1}/${controller.totalPages}")),
                          onPressed: () {
                            Get.dialog(AlertDialog(
                              title: const Text('Go to Page'),
                              content: TextFormField(
                                initialValue:
                                    '${controller.currentPage.value + 1}',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  labelText: 'Enter page numbber',
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (text) {
                                  controller.gotopage = int.tryParse(text);
                                },
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Can\'t be empty';
                                  }

                                  if (controller.gotopage == null) {
                                    return '"$text" is not a valid page number';
                                  } else {
                                    if (controller.gotopage! >=
                                            controller.totalPages.value ||
                                        controller.gotopage! <= 0) {
                                      return 'Page Not Exist';
                                    }
                                  }
                                  return null;
                                },
                                autofocus: true,
                                keyboardType: TextInputType.number,
                              ),
                              backgroundColor:
                                  Get.isDarkMode ? Colors.black : Colors.white,
                              actions: [
                                OutlinedButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Back')),
                                OutlinedButton(
                                    onPressed: () {
                                      if (controller.gotopage != null &&
                                              (controller.gotopage! <
                                                  controller
                                                      .totalPages.value) ||
                                          controller.gotopage! >= 0) {
                                        Get.back();
                                        controller
                                            .goToPage(controller.gotopage! - 1);
                                      }
                                    },
                                    child: const Text('Go'))
                              ],
                            ));
                          },
                        ),
                        IconButton(
                          color: Colors.grey,
                          onPressed: controller.handleTapNextPage,
                          icon: const Icon(Icons.navigate_next),
                        ),
                        IconButton(
                          color: Colors.grey,
                          onPressed: controller.redoPage,
                          icon: const Icon(Icons.redo_rounded),
                        ),
                        IconButton(
                          color: Colors.grey,
                          onPressed: controller.handleTappZoomIn,
                          icon: const Icon(Icons.zoom_in),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
      ),
    );
  }
}
