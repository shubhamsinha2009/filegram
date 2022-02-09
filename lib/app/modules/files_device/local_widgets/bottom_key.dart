
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';



class BtmKey extends StatelessWidget {

  const BtmKey({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        
        children: [
        LottieBuilder.asset('assets/key_to_unlock.json'),
          const SizedBox(
            height: 30,
          ),
          const Text("Opening Personal Documents is not allowed because these are protected files. \n  \n Try to share it! \n \nPlease try to open same file from Library which is already stored in case you have not deleted it from Library ",textScaleFactor: 1.5,),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () { Get.back(closeOverlays: true,); },
                  child: const Text('OK')), 
            ],
          ),
          
        ],

      ),
    );
  }
}

