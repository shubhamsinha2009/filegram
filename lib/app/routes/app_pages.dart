import 'package:get/get.dart';

import '../modules/app_drawer/bindings/app_drawer_binding.dart';
import '../modules/encrypt_decrypt/bindings/encrypt_decrypt_binding.dart';
import '../modules/encrypted_file_list/bindings/encrypted_file_list_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/middlewares/homemiddleware.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const intial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      bindings: [
        HomeBinding(),
        EncryptDecryptBinding(),
        AppDrawerBinding(),
        EncryptedFileListBinding(),
      ],
      middlewares: [HomeMiddleware()],
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // GetPage(
    //   name: _Paths.ENCRYPTED_FILE_LIST,
    //   page: () => EncryptedFileListView(),
    //   binding: EncryptedFileListBinding(),
    // ),
  ];
}
