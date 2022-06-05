import 'package:get/get.dart';

import '../modules/encrypt_decrypt/bindings/encrypt_decrypt_binding.dart';
import '../modules/encrypted_file_list/bindings/encrypted_file_list_binding.dart';
import '../modules/files_device/bindings/files_device_binding.dart';
import '../modules/gullak/bindings/gullak_binding.dart';
import '../modules/gullak/middlewares/gullakmiddleware.dart';
import '../modules/gullak/views/gullak_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/middlewares/homemiddleware.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/no_internet/bindings/no_internet_binding.dart';
import '../modules/settings/bindings/settings_binding.dart';

import '../modules/updatePhoneNumber/bindings/update_phone_number_binding.dart';
import '../modules/updatePhoneNumber/views/update_phone_number_view.dart';
import '../modules/view_pdf/bindings/view_pdf_binding.dart';
import '../modules/view_pdf/views/view_pdf_view.dart';
import '../modules/whatsapp_chat/bindings/whatsapp_chat_binding.dart';
import '../modules/whatsapp_chat/views/whatsapp_chat_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const intial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      transition: Transition.rightToLeftWithFade,
      bindings: [
        HomeBinding(),
        EncryptDecryptBinding(),
        SettingsBinding(),
        EncryptedFileListBinding(),
        NoInternetBinding(),
        FilesDeviceBinding(),
      ],
      middlewares: [HomeMiddleware()],
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      transition: Transition.rightToLeftWithFade,
      bindings: [
        LoginBinding(),
        NoInternetBinding(),
      ],
    ),
    GetPage(
      name: _Paths.viewPdf,
      page: () => const ViewPdfView(),
      binding: ViewPdfBinding(),
    ),
    GetPage(
      name: _Paths.whatsappChat,
      page: () => const WhatsappChatView(),
      binding: WhatsappChatBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.gullak,
      page: () => const GullakView(),
      binding: GullakBinding(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [GullakMiddleware()],
    ),
    GetPage(
      name: _Paths.updatePhoneNumber,
      page: () => const UpdatePhoneNumberView(),
      binding: UpdatePhoneNumberBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
