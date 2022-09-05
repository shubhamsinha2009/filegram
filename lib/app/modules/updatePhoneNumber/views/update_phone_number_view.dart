import 'package:filegram/app/data/provider/firestore_data.dart';
import 'package:filegram/app/modules/no_internet/views/no_internet_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../controllers/update_phone_number_controller.dart';

class UpdatePhoneNumberView extends GetView<UpdatePhoneNumberController> {
  const UpdatePhoneNumberView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey();
    return Obx(() => controller.isInternetConnected.isTrue
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Update Phone Number'),
            ),
            body: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                        'Please Update Your Phone Number .\n\nFor Now we only allow users to update phone number once.\n\nYour Phone Number Verification will be required before every Withdrawal.\n\nAs you cannot change your phone number for now. Please Keep in mind without verification of your provided Phone Number will be not allowded to withdraw any money from gullak\n',
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    IntlPhoneField(
                      initialCountryCode: 'IN',
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      onChanged: (phone) {
                        controller.phoneNumber = phone.completeNumber;
                      },
                      onCountryChanged: (country) {
                        // print('Country changed to: ' + country.name);
                      },
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          child: const Text(
                            'Send OTP',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (formKey.currentState?.validate() != null &&
                                formKey.currentState!.validate()) {
                              try {
                                controller
                                    .signInWithOtp(controller.phoneNumber)
                                    .then((value) => Get.dialog(AlertDialog(
                                          backgroundColor: Get.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          actionsAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          title: const Text('OTP Verification',
                                              softWrap: true,
                                              textAlign: TextAlign.center),
                                          content: TextFormField(
                                            maxLength: 6,
                                            onChanged: (value) =>
                                                controller.smsCode = value,
                                            // controller: controller.smsController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText:
                                                    '6 -digit xxxxxx  OTP'),
                                          ),
                                          actions: [
                                            OutlinedButton(
                                                onPressed: () async {
                                                  try {
                                                    controller
                                                        .signInWithPhoneNumber(
                                                            controller.smsCode)
                                                        .then((value) async {
                                                      if (value) {
                                                        if ((controller
                                                                .auth
                                                                .currentUser
                                                                ?.uid) !=
                                                            null) {
                                                          FirestoreData.updatePhoneUser(
                                                              id: ((controller
                                                                  .auth
                                                                  .currentUser
                                                                  ?.uid)!),
                                                              phoneNumber:
                                                                  controller
                                                                      .phoneNumber);
                                                        }
                                                        Get.back(
                                                            closeOverlays:
                                                                true);
                                                        Get.showSnackbar(
                                                            GetSnackBar(
                                                          backgroundColor: Get
                                                              .theme
                                                              .snackBarTheme
                                                              .backgroundColor!,
                                                          duration:
                                                              const Duration(
                                                                  seconds: 5),
                                                          title:
                                                              'Phone Number Status',
                                                          message:
                                                              'Phone Number Updated Successfully',
                                                          icon: const Icon(Icons
                                                              .error_outline),
                                                          snackPosition:
                                                              SnackPosition.TOP,
                                                        ));
                                                      }
                                                    });
                                                  } catch (e) {
                                                    Get.showSnackbar(
                                                        GetSnackBar(
                                                      backgroundColor: Get
                                                          .theme
                                                          .snackBarTheme
                                                          .backgroundColor!,
                                                      duration: const Duration(
                                                          seconds: 5),
                                                      title: 'Error',
                                                      message: e.toString(),
                                                      icon: const Icon(
                                                          Icons.error_outline),
                                                      snackPosition:
                                                          SnackPosition.TOP,
                                                    ));
                                                    Get.back();
                                                  }
                                                },
                                                child: const Text(
                                                    'Update Phone Number')),
                                            OutlinedButton(
                                                onPressed: () => Get.back(),
                                                child: const Text('Back')),
                                          ],
                                        )));
                              } catch (e) {
                                Get.showSnackbar(GetSnackBar(
                                  backgroundColor:
                                      Get.theme.snackBarTheme.backgroundColor!,
                                  duration: const Duration(seconds: 5),
                                  title: 'Cannot Open',
                                  message: e.toString(),
                                  icon: const Icon(Icons.error_outline),
                                  snackPosition: SnackPosition.TOP,
                                ));
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : const NoInternetView());
  }
}
