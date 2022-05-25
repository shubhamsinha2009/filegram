import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/firebase_analytics.dart';
import '../controllers/login_controller.dart';

class GoogleLogin extends StatelessWidget {
  const GoogleLogin({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final LoginController controller;
  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome ! \n Please Sign in to continue',
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(),
            controller.isSomethingLoading.value
                ? Lottie.asset(
                    'assets/loading.json',
                    fit: BoxFit.fill,
                  )
                : Lottie.asset(
                    'assets/google.json',
                    fit: BoxFit.fill,
                  ),
            const SizedBox(),
            TextButton.icon(
              onPressed: () async {
                try {
                  controller.isSomethingLoading.toggle();
                  await controller.signInWithGoogle();
                  if (await controller.userNotExists()) {
                    await controller.createNewUser();
                    await AnalyticsService.analytics.logSignUp(
                      signUpMethod: 'google_sign_in',
                    );
                  }
                  if (await controller.userNotExists()) {
                    await controller.createNewUser();
                    await AnalyticsService.analytics.logSignUp(
                      signUpMethod: 'google_sign_in',
                    );
                  }
                  controller.isSomethingLoading.toggle();
                  await AnalyticsService.analytics
                      .logScreenView(screenName: '/home');
                  Get.offAndToNamed('home');
                } catch (e) {
                  controller.isSomethingLoading.toggle();
                  Get.showSnackbar(GetSnackBar(
                    backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
                    title: 'Error',
                    message: e.toString(),
                    duration: const Duration(seconds: 5),
                  ));
                }
              },
              icon: const Icon(
                Icons.g_mobiledata_rounded,
                size: 40,
              ),
              label: const Text(
                'Sign In With Google',
                textScaleFactor: 1.5,
              ),
            ),
          ],
        ));
  }
}
