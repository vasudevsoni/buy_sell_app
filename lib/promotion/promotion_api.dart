import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PromotionApi {
  static const _apiKey = 'goog_buwpVOVcvMsRCbXmUmMUTtROgtK';

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.info);
    final configuration = PurchasesConfiguration(_apiKey);
    await Purchases.configure(configuration);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
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
    } on PlatformException catch (e) {
      switch (PurchasesErrorHelper.getErrorCode(e)) {
        case PurchasesErrorCode.purchaseCancelledError:
          showSnackBar(
            content: 'The purchase was cancelled by the user',
            color: redColor,
          );
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          showSnackBar(
            content:
                'The purchase was not completed. Please check your payment method and try again',
            color: redColor,
          );
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          showSnackBar(
            content: 'Purchases are not allowed on this device',
            color: redColor,
          );
          break;
        case PurchasesErrorCode.networkError:
          showSnackBar(
            content: 'Some network error has occurred. Please try again',
            color: redColor,
          );
          break;
        default:
          showSnackBar(
            content: 'Something has gone wrong. Please try again',
            color: redColor,
          );
      }
      return false;
    }
  }
}
