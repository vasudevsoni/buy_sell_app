import 'package:flutter/material.dart';

class MainProvider with ChangeNotifier {
  int currentPageIndex = 0;

  switchToPage(int index) {
    currentPageIndex = index;
    notifyListeners();
  }
}
