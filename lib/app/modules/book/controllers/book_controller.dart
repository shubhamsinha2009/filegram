import 'dart:io';

import 'package:filegram/app/core/extensions.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../core/helpers/ad_helper.dart';
import '../../../data/model/book_model.dart';
import '../../../data/provider/firestore_data.dart';
import '../../home/controllers/home_controller.dart';

class BookController extends GetxController {
  final homeController = Get.find<HomeController>();
  final isLoding = true.obs;
  Book book = Book(
      bookName: '', classNumber: 0, chapterNames: [], ncertDirectLinks: []);
  final total = 1.obs;
  final received = 0.obs;
  late http.StreamedResponse response;
  final List<int> _bytes = [];
  InterstitialAd? interstitialAd;
  final int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  final adDismissed = false.obs;
  final inlineAdIndex = 0;
  late BannerAd inlineBannerAd;
  final isInlineBannerAdLoaded = false.obs;
  final isBottomBannerAdLoaded = false.obs;
  late BannerAd bottomBannerAd;
  String get uid =>
      ((Get.arguments[0] as String) + (Get.arguments[1] as String)).sort;

  Future<void> getdetails(String url) async {
    try {
      response = await http.Client().send(http.Request('GET', Uri.parse(url)));
      total.value = response.contentLength ?? 0;
      received.value = 0;
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  Future<void> downloadFile(String filePath) async {
    final _file = File(filePath);
    try {
      response.stream.listen((value) {
        _bytes.addAll(value);
        received.value += value.length;
      }).onDone(() async {
        await _file.writeAsBytes(_bytes);
      });
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  void _createBottomBannerAd() {
    bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bookBottom,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBottomBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    if (isBottomBannerAdLoaded.isFalse) {
      bottomBannerAd.load();
    }
  }

  Future<void> createInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.viewBookPdf,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
            interstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialLoadAttempts += 1;
            interstitialAd = null;
            if (interstitialLoadAttempts <= maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ),
      );
    } on Exception catch (e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  AdWidget adWidget({required AdWithView ad}) {
    return AdWidget(ad: ad);
  }

  Future<void> showInterstitialAd({String? uid}) async {
    try {
      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              adDismissed.value = true;
              createInterstitialAd();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              createInterstitialAd();
            },
            onAdShowedFullScreenContent: (InterstitialAd ad) {});
        if (interstitialAd != null) {
          interstitialAd!.show();
        }
      }
    } on Exception catch (e) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
        title: 'Error',
        message: e.toString(),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  int getListViewItemIndex(int index) {
    if (index >= inlineAdIndex &&
        isInlineBannerAdLoaded.isTrue &&
        (book.chapterNames.length >= inlineAdIndex)) {
      return index - 1;
    }
    return index;
  }

  void _createInlineBannerAd() {
    inlineBannerAd = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: AdHelper.bookBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isInlineBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    inlineBannerAd.load();
  }

  Future<String> filesDocDir() async {
    //Get this App Document Directory
    //App Document Directory + folder name

    final Directory? _appDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir?.path}/Downloads');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  @override
  void onInit() {
    FirestoreData.getBook(uid)
        .then((value) {
          book = value;
        })
        .whenComplete(() => isLoding.value = false)
        .catchError((e) {
          Get.showSnackbar(GetSnackBar(
            backgroundColor: Get.theme.snackBarTheme.backgroundColor!,
            title: 'Error',
            message: e.toString(),
            duration: const Duration(seconds: 5),
          ));
        });
    if (isInlineBannerAdLoaded.isFalse) {
      _createInlineBannerAd();
    }
    createInterstitialAd();

    _createBottomBannerAd();

    super.onInit();
  }

  @override
  void onClose() {
    interstitialAd?.dispose();
    inlineBannerAd.dispose();
    bottomBannerAd.dispose();

    super.onClose();
  }
}
