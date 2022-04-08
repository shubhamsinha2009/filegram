import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_controller.dart';

class NoCloud extends StatelessWidget {
  const NoCloud({
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
            'All Files On Your Device Only',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Lottie.asset(
                'assets/no_cloud.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Text(
            'We never upload your files to our servers/clouds.',
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
