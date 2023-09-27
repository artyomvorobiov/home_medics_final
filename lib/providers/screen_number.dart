import 'package:flutter/material.dart';

class ScreenNumber with ChangeNotifier {
  static int number_of_screen = 0;

  void changeNumber() {
    number_of_screen = 0;
    // 0 и 3 по модулю 3 дают один результат, поэтому 3 отвечает за
    notifyListeners();
  }
}
