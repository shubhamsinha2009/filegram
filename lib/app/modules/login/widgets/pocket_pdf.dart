import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_controller.dart';

class PocketPdf extends StatelessWidget {
  const PocketPdf({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final LoginController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Protect/Secure Pdf Files',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Lottie.asset(
            'assets/pocket_pdf.json',
            fit: BoxFit.fill,
          ),
          const Text(
            '1.Prevent Pdf from theft(sharing,copying etc)\n\n2.Built in Pdf Viewer\n\n3.Owner Recognition & Source Link feature.',
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ]);
  }
}
