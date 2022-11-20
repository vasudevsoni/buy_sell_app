import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PromotionApi {
  static const _apiKey = 'goog_YqVpOhJguHsmKVtIsDuyQSYCPLe';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
    await Purchases.configure(configuration);
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
    } on PlatformException catch (_) {
      var errorCode = PurchasesErrorHelper.getErrorCode(_);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        showSnackBar(
          content: 'The purchase was cancelled by the user',
          color: redColor,
        );
        return false;
      } else if (errorCode == PurchasesErrorCode.purchaseInvalidError) {
        showSnackBar(
          content:
              'The purchase was not completed. Please check your payment method and try again',
          color: redColor,
        );
        return false;
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        showSnackBar(
          content: 'Purchases are not allowed on this device',
          color: redColor,
        );
        return false;
      } else if (errorCode == PurchasesErrorCode.networkError) {
        showSnackBar(
          content: 'Some network error has occurred. Please try again',
          color: redColor,
        );
        return false;
      } else {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
        return false;
      }
    }
  }
}
