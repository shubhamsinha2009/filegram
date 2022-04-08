import 'package:filegram/app/modules/login/controllers/controllers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PasswordlessEncryption extends StatelessWidget {
  const PasswordlessEncryption({
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
            'Passwordless Encryption',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Expanded(
            child: Lottie.asset(
              'assets/encryption.json',
              fit: BoxFit.contain,
            ),
          ),
          const Text(
            'No need to remember passwords of so many files',
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
