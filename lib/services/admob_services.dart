import 'dart:io';

class AdmobServices {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5910069150854222/9935906633';
    }
    return '';
  }
}
