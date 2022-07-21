import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class BooksController extends GetxController {
  // final isBottomBannerAdLoaded = false.obs;
  // late BannerAd bottomBannerAd;
  // final isBodyBannerAdLoaded = false.obs;
  // late BannerAd bodyBannerAd;

  var bookList = <Reference>[];
  final filteredbookList = <Reference>[].obs;
  final homeController = Get.find<HomeController>();
  final subjects = Get.arguments as Reference;

  void filterfileList(String fileName) {
    if (fileName.isEmpty) {
      filteredbookList.assignAll(bookList);
    } else {
      filteredbookList.assignAll(bookList
          .where((book) =>
              book.name.toLowerCase().contains(fileName.toLowerCase()))
          .toList());
    }
  }

  // void _createBottomBannerAd() {
  //   bottomBannerAd = BannerAd(
  //     adUnitId: AdHelper.booksBottomBanner,
  //     size: AdSize.banner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isBottomBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   if (isBottomBannerAdLoaded.isFalse) {
  //     bottomBannerAd.load();
  //   }
  // }

  // void _createBodyBannerAd() {
  //   bodyBannerAd = BannerAd(
  //     adUnitId: AdHelper.booksBodyBanner,
  //     size: AdSize.largeBanner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         isBodyBannerAdLoaded.value = true;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   if (isBodyBannerAdLoaded.isFalse) {
  //     bodyBannerAd.load();
  //   }
  // }

  // AdWidget adWidget({required AdWithView ad}) {
  //   return AdWidget(ad: ad);
  // }

  void firebaseStorage() {
    FirebaseStorage.instance
        .ref()
        .child(subjects.fullPath)
        .listAll()
        .then((ListResult value) {
      bookList = value.prefixes;
      filteredbookList.assignAll(bookList);
      //debugPrint(classList.toString());
    });
  }

  @override
  void onInit() {
    firebaseStorage();
    // if (kReleaseMode) {
    //   _createBottomBannerAd();
    //   _createBodyBannerAd();
    // }
    super.onInit();
  }
}
