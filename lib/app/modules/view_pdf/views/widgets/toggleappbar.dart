import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/view_pdf_controller.dart';

class ToggleAppBar extends StatelessWidget {
  const ToggleAppBar({
    super.key,
    required this.controller,
  });

  final ViewPdfController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            controller.hideAppBar.toggle();
            controller.pdfViewController!
                .setZoom(zoom: controller.hideAppBar.isFalse ? 0.8 : 1);
          },
          child: Container(
            height: 400,
            width: 180,
            color: Colors.transparent,
          ),
        ));
  }
}
