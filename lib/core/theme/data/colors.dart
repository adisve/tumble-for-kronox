import 'package:flutter/material.dart';

class CustomColors {
  static const orangePrimary = Color(0xffeb9605);
  static const orangePrimaryVariant = Color(0xffffbe29);

  static const lightColors = ColorScheme(
    primary: orangePrimary,
    primaryContainer: orangePrimaryVariant,
    secondary: Color(0xfff2f2f2),
    secondaryContainer: Color.fromARGB(255, 39, 39, 39),
    background: Colors.white,
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Color(0xff3b3b3b),
    onBackground: Color(0xff4d4d4d),
    onSurface: Color(0xff4d4d4d),
    onError: Colors.white,
    brightness: Brightness.light,
  );

  static const darkColors = ColorScheme(
    primary: orangePrimary,
    primaryContainer: orangePrimaryVariant,
    secondary: Color(0xff242424),
    secondaryContainer: Color.fromARGB(255, 189, 189, 189),
    background: Color(0xff080808),
    surface: Color.fromARGB(255, 19, 19, 19),
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Color(0xff9e9e9e),
    onBackground: Color(0xffd4d4d4),
    onSurface: Color(0xffd4d4d4),
    onError: Colors.white,
    brightness: Brightness.dark,
  );
}
