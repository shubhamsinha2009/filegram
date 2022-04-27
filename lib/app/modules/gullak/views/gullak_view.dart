import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/gullak_controller.dart';

class GullakView extends GetView<GullakController> {
  const GullakView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.savings_rounded,
                color: Color.fromARGB(255, 194, 103, 70)),
            SizedBox(
              width: 10,
            ),
            Text('Gullak'),
          ],
        ),
        // leading: const Icon(Icons.savings_rounded,
        //     color: Color.fromARGB(255, 194, 103, 70)),
      ),
      body: ListView(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 0,
            left: 15,
            right: 15,
          ),
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black54,
                  Colors.black87,
                ],
              ),
              //color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade900,
                  offset: const Offset(5, 5),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.grey.shade800,
                  offset: const Offset(-4, -4),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ]),
          child: Column(
            children: [
              Obx(() => Text('${controller.gullak.value.sikka} 🟡',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.amber,
                  ))),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '100 Sikka in Gullak = Rs 10.00',
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Obx(() => LinearProgressIndicator(
                    value: controller
                        .getLinearValue(controller.gullak.value.sikka),
                    backgroundColor: Colors.grey,
                    color: Colors.purple,
                    minHeight: 10,
                  )),
              const SizedBox(
                height: 10,
              ),
              Obx(() => Text(
                    "You've reached ${controller.getLinearValue(controller.gullak.value.sikka)}% of your payment threshold(1,00,000 Sikka)",
                    softWrap: true,
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    controller.gullak.value.withdrawalLink.isEmpty
                        ? Get.dialog(AlertDialog(
                            title: const Text(
                                'Sorry , Yet Not Qualified for Withdrawal '),
                            content: const Text(
                                'You can withdraw money between 1st - 5th day of every month only if your payment threshold is compleleted '),
                            actions: [
                              OutlinedButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('OK'))
                            ],
                            backgroundColor: Colors.black,
                          ))
                        : await launch(controller.gullak.value.withdrawalLink);
                  } on Exception {
                    Get.showSnackbar(const GetSnackBar(
                      messageText: Text('Could not  able to open it'),
                      icon: Icon(Icons.error_outline),
                      snackPosition: SnackPosition.TOP,
                      duration: Duration(seconds: 3),
                    ));
                  }
                },
                child: const Text(
                  'Withdrawal',
                  softWrap: true,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '*** Paid monthly if the total is at least 1,00,000 🟡(Sikka)***',
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.only(
        //     top: 15,
        //     bottom: 0,
        //     left: 15,
        //     right: 15,
        //   ),
        //   margin: const EdgeInsets.all(15),
        //   decoration: BoxDecoration(
        //       gradient: const LinearGradient(
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //         colors: [
        //           Colors.black54,
        //           Colors.black87,
        //         ],
        //       ),
        //       //color: Colors.black87,
        //       borderRadius: BorderRadius.circular(20),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.grey.shade900,
        //           offset: const Offset(5, 5),
        //           blurRadius: 5,
        //           spreadRadius: 1,
        //         ),
        //         BoxShadow(
        //           color: Colors.grey.shade800,
        //           offset: const Offset(-4, -4),
        //           blurRadius: 5,
        //           spreadRadius: 1,
        //         )
        //       ]),
        //   child: Column(
        //     children: const [
        //       Text(
        //         'Transactions',
        //         textAlign: TextAlign.center,
        //         softWrap: true,
        //         style: TextStyle(
        //           fontWeight: FontWeight.w800,
        //           fontSize: 25,
        //         ),
        //       ),
        //     ],
        //   ),
        // )
      ]),
    );
  }
}
