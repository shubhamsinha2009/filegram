part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const onBOARDING = _Paths.onBOARDING;
  static const login = _Paths.login;
  // static const ENCRYPTED_FILE_LIST = _Paths.ENCRYPTED_FILE_LIST;
  //static const NO_INTERNET = _Paths.NO_INTERNET;
  // static const ADS = _Paths.ADS;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const onBOARDING = '/onboarding';
  static const login = '/login';
  //static const ENCRYPTED_FILE_LIST = '/encrypted-file-list';
  // static const NO_INTERNET = '/no-internet';
  // static const ADS = '/ads';
}
