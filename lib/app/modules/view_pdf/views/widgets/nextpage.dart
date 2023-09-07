import 'package:flutter/material.dart';

import '../../controllers/view_pdf_controller.dart';

class NextPage extends StatelessWidget {
  const NextPage({
    super.key,
    required this.controller,
  });

  final ViewPdfController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => controller.handleTapNextPage(),
          child: Container(
            height: 400,
            width: 80,
            color: Colors.transparent,
          ),
        ));
  }
}
