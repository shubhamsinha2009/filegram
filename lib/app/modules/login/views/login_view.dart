import 'package:filegram/app/modules/no_internet/views/no_internet_view.dart';

import '../controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isInternetConnected.isTrue
        ? Scaffold(
            body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome, Please Sign in to continue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                        await controller.analytics.logSignUp(
                          signUpMethod: 'google_sign_in',
                        );
                      }
                      controller.isSomethingLoading.toggle();
                      await controller.analytics
                          .logScreenView(screenName: '/home');
                      Get.offAndToNamed('home');
                    } catch (e) {
                      controller.isSomethingLoading.toggle();
                      Get.showSnackbar(GetSnackBar(
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
            ),
          ))
        : const NoInternetView());
  }
}
