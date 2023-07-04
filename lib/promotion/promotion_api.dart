import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RemoveAds {
  static const idRemoveAds = 'remove_ads_offering';
}

class PromotionApi {
  static const _apiKey = 'goog_buwpVOVcvMsRCbXmUmMUTtROgtK';

  static Future<void> init() async {
    final services = FirebaseServices();
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = services.user!.uid);
  }

  static Future<Offering> fetchRemoveAdsOffer(String id) async {
    final offers = await fetchOffers();
    return offers.where((offer) => id == offer.identifier).first;
  }

  static Future<List<Offering>> fetchOffers({bool all = true}) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (!all) {
        final current = offerings.current;
        return current == null ? [] : [current];
      } else {
        return offerings.all.values.toList();
      }
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
