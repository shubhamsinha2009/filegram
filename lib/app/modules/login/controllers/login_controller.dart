import 'dart:async';
import 'package:filegram/app/core/services/firebase_analytics.dart';
import 'package:filegram/app/data/model/user_model.dart';
import 'package:filegram/app/data/provider/firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final analytics = AnalyticsService.analytics;
  final _user = UserModel().obs;
  final auth = FirebaseAuth.instance;
  final isSomethingLoading = false.obs;

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
//   var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult != ConnectivityResult.none) {
//       if (Get.isDialogOpen != null && Get.isDialogOpen == true) {
//         Get.back();
//       }
//     } else {
//       Get.defaultDialog(
//         title: "No Netwok Connection",
//         middleText:
//             "Mobile Data is disabled. Enable mobile data or connect your phone to Wifi to use the application",
//         barrierDismissible: false,
//         onWillPop: () async => false,
//       );
//     }
//  _connectivitySubscription = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) async {
//       if (result != ConnectivityResult.none) {
//         if (Get.isDialogOpen != null && Get.isDialogOpen == true) {
//           Get.back();
//         }
//       } else {
//         Get.defaultDialog(
//           title: "No Netwok Connection",
//           middleText:
//               "Mobile Data is disabled. Enable mobile data or connect your phone to Wifi to use the application",
//           barrierDismissible: false,
//           onWillPop: () async => false,
//         );
//       }
//       // Got a new connectivity status!
//     });

    analytics.setCurrentScreen(screenName: 'login');
    analytics.logScreenView(screenName: 'login_screen');
    super.onInit();
  }
}
