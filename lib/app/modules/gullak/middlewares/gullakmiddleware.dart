import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

import '../../../routes/app_pages.dart';

class GullakMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = FirebaseAuth.instance;

    bool checkPhoneNumberLinked() {
      final phoneNumber = auth.currentUser?.phoneNumber;
      return phoneNumber != null && phoneNumber.isNotEmpty ? true : false;
    }

    if (checkPhoneNumberLinked()) {
      return null;
    } else {
      return const RouteSettings(name: Routes.updatePhoneNumber);
    }
  }
}
