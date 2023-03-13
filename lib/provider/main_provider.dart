import 'package:flutter/material.dart';

class AppNavigationProvider with ChangeNotifier {
  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;

  void switchToPage(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
}
