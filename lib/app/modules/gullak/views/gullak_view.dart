import 'package:filegram/app/modules/no_internet/views/no_internet_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controllers/gullak_controller.dart';

class GullakView extends GetView<GullakController> {
  const GullakView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isInternetConnected.isTrue
        ? Scaffold(
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
              Obx(
                () => controller.istopBannerAdLoaded.isTrue
                    ? SizedBox(
                        height: controller.topBannerAd?.size.height.toDouble(),
                        width: controller.topBannerAd?.size.width.toDouble(),
                        child: controller.adWidget(ad: controller.topBannerAd!),
                      )
                    : const SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Get.isDarkMode ? Colors.black54 : Colors.white70,
                        Get.isDarkMode ? Colors.black87 : Colors.white,
                      ],
                    ),
                    //color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Get.isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade500,
                        offset: const Offset(5, 5),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Get.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade400,
                        offset: const Offset(-4, -4),
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    ]),
                child: Column(
                  children: [
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${controller.gullak.value.sikka}',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber,
                                )),
                            const Icon(Icons.circle,
                                color: Colors.amber, size: 30),
                          ],
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      '10 Sikka in Gullak = Rs 1.00',
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
                          value: controller.gullak.value.sikka / 10000,
                          backgroundColor: Colors.grey,
                          color: Colors.purple,
                          minHeight: 10,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Obx(() => Text(
                          "You've reached ${controller.gullak.value.sikka / 100}% of your payment threshold(10,000 Sikka)",
                          softWrap: true,
                          textAlign: TextAlign.center,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          // Get.dialog(AlertDialog(
                          //   title: const Text('Rewarded Feature'),
                          //   content: const Text(
                          //       'Please watch full rewarded ad to withdraw money and Please click withdraw only if you qualified else you will not get any reward. You can withdraw money between 1st - 5th day of every month only if your payment threshold is compleleted '),
                          //   actions: [
                          //     OutlinedButton(
                          //         onPressed: () => Get.back(),
                          //         child: const Text('Back')),
                          //     OutlinedButton(
                          //         onPressed: () {
                          //           controller.rewardedInterstitialAd.show(
                          //               onUserEarnedReward: (ad, reward) async {
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
                                  backgroundColor: Get.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ))
                              : await launchUrlString(
                                  controller.gullak.value.withdrawalLink,
                                  mode: LaunchMode.externalApplication);
                          //           });
                          //         },
                          //         child: const Text('Withdraw'))
                          //   ],
                          //   backgroundColor: Colors.black,
                          // ));
                        } on Exception {
                          Get.showSnackbar(GetSnackBar(
                            backgroundColor:
                                Get.theme.snackBarTheme.backgroundColor!,
                            messageText:
                                const Text('Could not  able to open it'),
                            icon: const Icon(Icons.error_outline),
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 3),
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
                      '*** Paid monthly if the total is at least 10,000 (Sikka)*** ',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    const Text(
                      '*** Everytime someone open pdf you get few Sikka *** ',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    const Text(
                      '*** Owner will not get any sikka for opening their own pdf *** ',
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
          )
        : const NoInternetView());
  }
}
