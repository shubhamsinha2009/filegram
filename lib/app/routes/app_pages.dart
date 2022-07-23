import 'package:get/get.dart';

import '../modules/book_page/bindings/book_page_binding.dart';
import '../modules/book_page/views/book_page_view.dart';
import '../modules/books/bindings/books_binding.dart';
import '../modules/books/views/books_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/download/bindings/download_binding.dart';
import '../modules/download/views/download_view.dart';
import '../modules/downloaded/bindings/downloaded_binding.dart';
import '../modules/downloaded/views/downloaded_view.dart';
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
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/subject/bindings/subject_binding.dart';
import '../modules/subject/views/subject_view.dart';
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
        DashboardBinding(),
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
      bindings: [
        ViewPdfBinding(),
        NoInternetBinding(),
      ],
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
      bindings: [
        GullakBinding(),
        NoInternetBinding(),
      ],
      transition: Transition.rightToLeftWithFade,
      middlewares: [GullakMiddleware()],
    ),
    GetPage(
      name: _Paths.updatePhoneNumber,
      page: () => const UpdatePhoneNumberView(),
      bindings: [
        UpdatePhoneNumberBinding(),
        NoInternetBinding(),
      ],
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.subject,
      page: () => const SubjectView(),
      binding: SubjectBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.books,
      page: () => const BooksView(),
      transition: Transition.rightToLeft,
      binding: BooksBinding(),
    ),
    GetPage(
      name: _Paths.bookPage,
      page: () => const BookPageView(),
      binding: BookPageBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.download,
      page: () => const DownloadView(),
      binding: DownloadBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.downloaded,
      page: () => const DownloadedView(),
      binding: DownloadedBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
