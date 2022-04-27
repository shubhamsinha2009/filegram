import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_controller.dart';

class Gullak extends StatelessWidget {
  const Gullak({
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
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Gullak - Earn from your pdfs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        Expanded(
          child: Lottie.asset(
            'assets/gullak.json',
            fit: BoxFit.contain,
          ),
        ),
        const Text(
          'Three Simple Steps to start your earning \n\n1.Open/Upload/Encrypt your pdfs in filegram \n\n2. Share your pdfs through filegram \n\n3.Earn from every view of pdf in filegram',
          softWrap: true,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
