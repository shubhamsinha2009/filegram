import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../controllers/whatsapp_chat_controller.dart';

class WhatsappChatView extends GetView<WhatsappChatController> {
  const WhatsappChatView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Click to Chat',
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Lottie.asset(
                  'assets/whatsapp.json',
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 0,
                    width: 0,
                  ),
                ),
              ),
              const Text(
                  'Open Whatsapp Chat without saving any number in your contact.\n\nJust type your number , select country and click send to open whatsapp chat.\n',
                  softWrap: true,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                      'Send',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() != null &&
                          _formKey.currentState!.validate()) {
                        try {
                          await launchUrlString(
                              'whatsapp://send?phone=${controller.phoneNumber}',
                              mode: LaunchMode.externalNonBrowserApplication);
                        } catch (e) {
                          Get.showSnackbar(GetSnackBar(
                            backgroundColor:
                                Get.isDarkMode ? Colors.black : Colors.white,
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
    );
  }
}
