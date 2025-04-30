import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        secondary: Colors.blueAccent,  // Set secondary color as the accent color
      ),
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black87),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.blueGrey,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        secondary: Colors.blueAccent,  // Set secondary color as the accent color
      ),
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white70),
      ),
    );
  }
}
