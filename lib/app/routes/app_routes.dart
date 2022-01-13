part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const onBOARDING = _Paths.onBOARDING;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const onBOARDING = '/onboarding';
}
