import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
      body: Container(
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
        child: ListView(
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
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
                  value:
                      controller.getLinearValue(controller.gullak.value.sikka),
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
              onPressed: () => Get.showSnackbar(
                const GetSnackBar(
                  message: 'Wihdrawal Feature coming soon',
                  // backgroundColor: Colors.amber,
                  duration: Duration(seconds: 3),
                  snackPosition: SnackPosition.TOP,
                ),
              ),
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
    );
  }
}
