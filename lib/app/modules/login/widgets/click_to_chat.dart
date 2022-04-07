import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_controller.dart';

class ClicktoChat extends StatelessWidget {
  const ClicktoChat({
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
            'Whatsapp Click to Chat',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Lottie.asset(
            'assets/whatsapp.json',
            fit: BoxFit.fill,
          ),
          const Text(
            'Open Whatsapp Chat without saving any number in your contact.',
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ]);
  }
}
