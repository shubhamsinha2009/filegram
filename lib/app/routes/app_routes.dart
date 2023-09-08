part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const onBOARDING = _Paths.onBOARDING;
  static const login = _Paths.login;
  static const viewPdf = _Paths.viewPdf;

  static const gullak = _Paths.gullak;
  static const updatePhoneNumber = _Paths.updatePhoneNumber;
  static const docpermission = _Paths.docpermission;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const onBOARDING = '/onboarding';
  static const login = '/login';
  static const viewPdf = '/view-pdf';

  static const gullak = '/gullak';
  static const updatePhoneNumber = '/update-phone-number';
  static const docpermission = '/docpermission';
}
