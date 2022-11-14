import 'package:buy_sell_app/promotion/promotion_api.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/utils.dart';

class PromoteListingScreen extends StatefulWidget {
  final String productId;
  const PromoteListingScreen({
    super.key,
    required this.productId,
  });

  @override
  State<PromoteListingScreen> createState() => _PromoteListingScreenState();
}

class _PromoteListingScreenState extends State<PromoteListingScreen> {
  final FirebaseServices _services = FirebaseServices();
  List<Package> packages = [];

  @override
  void initState() {
    fetchOffers();
    super.initState();
  }

  Future fetchOffers() async {
    final offerings = await PromotionApi.fetchOffers();
    if (offerings.isEmpty) {
      showSnackBar(
        content: 'No plans found',
        color: redColor,
      );
      return;
    }
    if (mounted) {
      setState(() {
        packages = offerings
            .map((offer) => offer.availablePackages)
            .expand((pair) => pair)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Package package = packages.first;
    final product = package.storeProduct;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Promote your product',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Offers',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final isSuccess = await PromotionApi.purchasePackage(package);
                  if (isSuccess) {
                    _services.promoteListingToTop(listingId: widget.productId);
                    Get.back();
                    return;
                  }
                  showSnackBar(
                    content:
                        'Purchase was not completed. Please try again after some time',
                    color: redColor,
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: blueColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                product.priceString,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: whiteColor,
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.check,
                              color: whiteColor,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                product.description,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: greyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: const [
                            Icon(
                              FontAwesomeIcons.check,
                              color: whiteColor,
                              size: 16,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                'Reach upto 2 times more buyers',
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: greyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: const [
                            Icon(
                              FontAwesomeIcons.check,
                              color: whiteColor,
                              size: 16,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                'One-time purchase',
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: greyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
