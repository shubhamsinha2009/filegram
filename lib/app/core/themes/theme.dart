import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      elevation: 4,
      color: Colors.black,
      centerTitle: true,
    ),
    cardColor: Colors.black,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Colors.black,
    ),
    textTheme: TextTheme(
      headline6: GoogleFonts.averiaSerifLibre(
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      button: GoogleFonts.averiaSerifLibre(),
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
    appBarTheme: AppBarTheme(
      elevation: 4,
      color: Colors.red,
      centerTitle: true,
      titleTextStyle: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      actionsIconTheme: const IconThemeData(
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
    textTheme: TextTheme(
      bodyText1: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      bodyText2: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      subtitle1: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      subtitle2: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      headline6: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      headline1: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      headline2: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      headline3: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      headline4: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      headline5: GoogleFonts.averiaSerifLibre(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 25,
      ),
      button: GoogleFonts.averiaSerifLibre(),
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
