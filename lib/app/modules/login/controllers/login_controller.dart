import 'dart:async';
import '../../no_internet/controllers/no_internet_controller.dart';

import '../../../core/services/firebase_analytics.dart';
import '../../../data/model/user_model.dart';
import '../../../data/provider/firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final _user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final isSomethingLoading = false.obs;
  final isInternetConnected =
      Get.find<NoInternetController>().isInternetConnected;

  Future<void> createNewUser() async {
    return FirestoreData.createNewUser(_user(UserModel(
      id: auth.currentUser?.uid,
      emailId: auth.currentUser?.email,
      photoUrl: auth.currentUser?.photoURL,
      name: auth.currentUser?.displayName,
    )));
  }

  Future<void> deleteUser() => FirestoreData.deleteUser(auth.currentUser?.uid);

  Future<bool> userNotExists() =>
      FirestoreData.userNotExists(auth.currentUser?.uid);

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception {
      rethrow;
    }
  }

  @override
  void onInit() async {
    AnalyticsService.analytics.setCurrentScreen(screenName: 'login');
    AnalyticsService.analytics.logScreenView(screenName: 'login_screen');
    super.onInit();
  }
}
