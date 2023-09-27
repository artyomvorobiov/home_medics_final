import 'package:flutter/material.dart';

class ColorTheme with ChangeNotifier {
  int darkColor = 0xFF286211;
  int secdarkColor = 0xFFf2f3f4;

  int lightColor = 0xFFA3C7D6;
  int secLightColor = 0xFF3F3B6C;

  static int mainFirstColor = 0xFF7286211,
      mainSecColor = 0xFFf2f3f4,
      premiumColor = 0xFFFF0000;
  void switchTheme(bool isDarkTheme) {
    mainFirstColor = isDarkTheme ? darkColor : lightColor;
    mainSecColor = isDarkTheme ? secdarkColor : secLightColor;
    notifyListeners();
  }

  int get currentFirstColor {
    return mainFirstColor;
  }

  int get currentSecondColor {
    return mainSecColor;
  }
}
