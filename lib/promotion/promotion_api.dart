import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PromotionApi {
  static const _apiKey = 'goog_YqVpOhJguHsmKVtIsDuyQSYCPLe';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    if (Platform.isAndroid) {
      PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
      await Purchases.configure(configuration);
    }
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (_) {
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (_) {
      return false;
    }
  }
}
