part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const onBOARDING = _Paths.onBOARDING;
  static const login = _Paths.login;
  static const viewPdf = _Paths.viewPdf;
  static const whatsappChat = _Paths.whatsappChat;
  static const gullak = _Paths.gullak;
  static const updatePhoneNumber = _Paths.updatePhoneNumber;
  static const subject = _Paths.subject;
  static const books = _Paths.books;
  static const bookPage = _Paths.bookPage;
  static const download = _Paths.download;
  static const downloaded = _Paths.downloaded;
  static const profile = _Paths.profile;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const onBOARDING = '/onboarding';
  static const login = '/login';
  static const viewPdf = '/view-pdf';
  static const whatsappChat = '/whatsappChat';
  static const gullak = '/gullak';
  static const updatePhoneNumber = '/update-phone-number';
  static const subject = '/subject';
  static const books = '/books';
  static const bookPage = '/book-page';
  static const download = '/download';
  static const downloaded = '/downloaded';
  static const profile = '/profile';
}
