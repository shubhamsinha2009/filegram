import 'package:flutter/material.dart';

class Themes {
  static final ThemeData appDarkTheme = ThemeData(
    chipTheme: const ChipThemeData(
        backgroundColor: Colors.black,
        disabledColor: Colors.transparent,
        selectedColor: Colors.black,
        secondarySelectedColor: Colors.black,
        padding: EdgeInsets.all(5),
        shape: StadiumBorder(side: BorderSide(color: Colors.white)),
        labelStyle: TextStyle(color: Colors.white),
        secondaryLabelStyle: TextStyle(color: Colors.white),
        brightness: Brightness.dark),
    dividerColor: Colors.white,
    dividerTheme: const DividerThemeData(color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      labelStyle: TextStyle(color: Colors.white),
    ),
    disabledColor: Colors.white,
    bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.black,
        modalBackgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)))),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    canvasColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    backgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      color: Colors.black,
    ),
    cardColor: Colors.black,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white12,
      foregroundColor: Colors.white60,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Colors.black,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white70,
        backgroundColor: Colors.white10,
        shadowColor: Colors.grey.shade900,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white70,
      ),
    ),
    textTheme: const TextTheme(
      headline6: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
    ),
  );

  static final ThemeData appLightTheme = ThemeData(
    chipTheme: const ChipThemeData(
        backgroundColor: Colors.black,
        disabledColor: Colors.transparent,
        selectedColor: Colors.black,
        secondarySelectedColor: Colors.black,
        padding: EdgeInsets.all(5),
        shape: StadiumBorder(side: BorderSide(color: Colors.white)),
        labelStyle: TextStyle(color: Colors.white),
        secondaryLabelStyle: TextStyle(color: Colors.white),
        brightness: Brightness.dark),
    dividerColor: Colors.white,
    dividerTheme: const DividerThemeData(color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      labelStyle: TextStyle(color: Colors.white),
    ),
    disabledColor: Colors.white,
    bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.black,
        modalBackgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)))),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    primaryColor: Colors.redAccent,
    canvasColor: Colors.red,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    // drawerTheme: DrawerThemeData(
    // ),
    appBarTheme: const AppBarTheme(
      elevation: 4,
      color: Colors.red,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    cardColor: Colors.black,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.red,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Colors.black,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.deepOrange,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white70,
        backgroundColor: Colors.white10,
        shadowColor: Colors.grey.shade900,
      ),
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      subtitle1: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      subtitle2: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      headline6: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      headline1: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      headline2: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      headline3: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      headline4: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      headline5: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      button: TextStyle(),
    ),
  );

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }
}
