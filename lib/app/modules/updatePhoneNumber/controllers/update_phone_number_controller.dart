import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../no_internet/controllers/no_internet_controller.dart';

class UpdatePhoneNumberController extends GetxController {
  late String phoneNumber;
  late String smsCode;
  final auth = FirebaseAuth.instance;
  late String verificationID;
  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;

  Future<void> signInWithOtp(String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          Get.back();
          await auth.currentUser?.linkWithCredential(credential);

          Get.showSnackbar(GetSnackBar(
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
            duration: const Duration(seconds: 10),
            title: '"Loggged In "',
            message:
                "Phone number automatically verified and user signed in: ${auth.currentUser?.uid}",
            snackPosition: SnackPosition.TOP,
          ));
        },
        verificationFailed: (FirebaseAuthException authException) {
          Get.back();
          if (authException.code == 'invalid-phone-number') {
            Get.showSnackbar(GetSnackBar(
              backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
              duration: const Duration(seconds: 5),
              title: 'Phone Verfication Failed',
              message: 'The provided phone number is not valid.',
              snackPosition: SnackPosition.TOP,
            ));
          } else {
            Get.showSnackbar(GetSnackBar(
              backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
              duration: const Duration(seconds: 5),
              title: 'Phone Verfication Failed',
              message:
                  ' Code: ${authException.code}. Message: ${authException.message}',
              snackPosition: SnackPosition.TOP,
            ));
          }
        },
        codeSent: (String verificationId, int? forceResendingToken) async {
          Get.showSnackbar(GetSnackBar(
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
            duration: const Duration(seconds: 5),
            title: "OTP ",
            message: 'Please check your phone for the verification code.',
            snackPosition: SnackPosition.TOP,
          ));
          verificationID = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationID = verificationId;
        },
      );
    } catch (e) {
      Get.back();
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        duration: const Duration(seconds: 5),
        title: 'Verfication Error',
        message: "Failed to Verify Phone Number: $e",
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<bool> signInWithPhoneNumber(String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
          smsCode: smsCode, verificationId: verificationID);

      await auth.currentUser?.linkWithCredential(credential);

      return true;
    } catch (e) {
      Get.back();
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        duration: const Duration(seconds: 5),
        title: 'Failed to sign in:',
        message: e.toString(),
        snackPosition: SnackPosition.TOP,
      ));
      return false;
    }
  }
}
