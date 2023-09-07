import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/view_pdf_controller.dart';

class BookMark extends StatelessWidget {
  const BookMark({
    super.key,
    required this.controller,
  });

  final ViewPdfController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Obx(() => controller.hideAppBar.isTrue
          ? GestureDetector(
              onTap: () {
                controller.bookmarks.contains(controller.currentPage.value)
                    ? controller.bookmarks.remove(controller.currentPage.value)
                    : controller.bookmarks.add(controller.currentPage.value);
              },
              child: Container(
                alignment: Alignment.topRight,
                color: Colors.transparent,
                height: 100,
                width: 100,
                child:
                    controller.bookmarks.contains(controller.currentPage.value)
                        ? const Icon(
                            Icons.bookmark,
                            color: Colors.blue,
                            size: 30,
                          )
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
              ),
            )
          : const SizedBox(
              width: 0,
              height: 0,
            )),
    );
  }
}
