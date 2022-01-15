import 'package:filegram/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = FirebaseAuth.instance;

    bool checkLoggedIn() {
      return auth.currentUser != null ? true : false;
    }

    if (checkLoggedIn()) {
      return null;
    } else {
      return const RouteSettings(name: Routes.login);
    }
  }
}
