import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

SafeArea noInternetConnection() {
  return SafeArea(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Switch On Internet Connection! ",
            style: TextStyle(
                fontSize: 25,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 50,
          ),
          Lottie.asset('assets/no_internet.json'),
          const SizedBox(
            height: 50,
          ),
          const Text(
            "Filegram Needs Internet To Provide Its Services",
            style: TextStyle(
                fontSize: 25,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
