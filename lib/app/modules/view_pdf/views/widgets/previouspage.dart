import 'package:flutter/material.dart';

import '../../controllers/view_pdf_controller.dart';

class PreviousPage extends StatelessWidget {
  const PreviousPage({
    super.key,
    required this.controller,
  });

  final ViewPdfController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => controller.handleTapPreviousPage(),
          child: Container(
            height: 400,
            width: 80,
            color: Colors.transparent,
          ),
        ));
  }
}
