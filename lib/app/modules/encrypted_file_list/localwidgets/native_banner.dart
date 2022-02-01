import 'package:filegram/app/modules/encrypted_file_list/controllers/encrypted_file_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

NativeAd homeAd(EncryptedFileListController controller) {
  return NativeAd(
    controller: controller.nativeAdController,
    height: 300,
    builder: (context, child) {
      return Material(
        color: Colors.black,
        elevation: 8,
        child: child,
      );
    },
    buildLayout: fullBuilder,
    loading: const SizedBox(
      height: 0,
      width: 0,
    ),
    error: const SizedBox(
      height: 0,
      width: 0,
    ),
    icon: AdImageView(size: 40),
    headline: AdTextView(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      maxLines: 1,
    ),
    media: AdMediaView(
      height: 180,
      width: MATCH_PARENT,
      elevation: 6,
      //elevationColor: Colors.deepPurpleAccent,
    ),
    attribution: AdTextView(
      width: WRAP_CONTENT,
      height: WRAP_CONTENT,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      margin: const EdgeInsets.only(right: 4),
      maxLines: 1,
      text: 'Ad',
      decoration: AdDecoration(
        borderRadius: AdBorderRadius.all(20),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    button: AdButtonView(
      elevation: 18,
      elevationColor: Colors.amber,
      height: MATCH_PARENT,
    ),
    ratingBar: AdRatingBarView(starsColor: Colors.white),
  );
}

AdLayoutBuilder get fullBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribuition, button) {
      return AdLinearLayout(
        padding: const EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        decoration: AdDecoration(
          backgroundColor: Colors.black,
        ),
        children: [
          media,
          AdLinearLayout(
            children: [
              icon,
              AdLinearLayout(children: [
                headline,
                AdLinearLayout(
                  children: [attribuition, advertiser, ratingBar],
                  orientation: HORIZONTAL,
                  width: MATCH_PARENT,
                ),
              ], margin: const EdgeInsets.only(left: 4)),
            ],
            gravity: LayoutGravity.center_horizontal,
            width: WRAP_CONTENT,
            orientation: HORIZONTAL,
            margin: const EdgeInsets.only(top: 6),
          ),
          AdLinearLayout(
            children: [button],
            orientation: HORIZONTAL,
          ),
        ],
      );
    };
