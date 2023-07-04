import 'package:buy_sell_app/promotion/promotion_api.dart';
import 'package:buy_sell_app/promotion/boost_info_screen.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/utils.dart';
import '../widgets/custom_loading_indicator.dart';

class PromoteListingScreen extends StatefulWidget {
  final String productId;
  final String imageUrl;
  final String title;
  const PromoteListingScreen({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.title,
  });

  @override
  State<PromoteListingScreen> createState() => _PromoteListingScreenState();
}

class _PromoteListingScreenState extends State<PromoteListingScreen> {
  final FirebaseServices _services = FirebaseServices();
  List<Package> packages = [];
  Package? package;
  StoreProduct? product;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPromotionOffers();
  }

  Future<void> fetchPromotionOffers() async {
    setState(() {
      isLoading = true;
    });
    await PromotionApi.init();
    final offerings = await PromotionApi.fetchOffers(all: false);
    if (mounted) {
      setState(() {
        packages = offerings
            .map((offer) => offer.availablePackages)
            .expand((pair) => pair)
            .toList();
        package = packages.first;
        product = package!.storeProduct;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Promote your product',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: isLoading
          ? const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: blackColor,
                    child: Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.20,
                          height: size.width * 0.20,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                memCacheHeight: (size.height * 0.20).round(),
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    Ionicons.alert_circle_outline,
                                    size: 15,
                                    color: redColor,
                                  );
                                },
                                placeholder: (context, url) {
                                  return const Icon(
                                    Ionicons.image,
                                    size: 15,
                                    color: lightBlackColor,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.interTight(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Available Packages',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Ionicons.checkbox_outline,
                          color: blueColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: blueColor,
                        border: greyBorder,
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
                                    product!.title.toString(),
                                    style: GoogleFonts.interTight(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        product!.priceString.toString(),
                                        textAlign: TextAlign.end,
                                        style: GoogleFonts.interTight(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: whiteColor,
                                        ),
                                      ),
                                      Text(
                                        '₹100.00',
                                        textAlign: TextAlign.end,
                                        style: GoogleFonts.interTight(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: whiteColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationStyle:
                                              TextDecorationStyle.wavy,
                                          decorationColor: blackColor,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: whiteColor,
                              height: 20,
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Ionicons.arrow_up_circle_outline,
                                  color: whiteColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    product!.description,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.interTight(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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
                              children: [
                                const Icon(
                                  Ionicons.trending_up,
                                  color: whiteColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    'Reach more buyers',
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.interTight(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: greyColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: whiteColor,
                              height: 20,
                              thickness: 1,
                            ),
                            CustomButton(
                              text: 'Buy Now',
                              onPressed: () async {
                                final isSuccess =
                                    await PromotionApi.purchasePackage(
                                        package!);
                                if (isSuccess) {
                                  _services.promoteListingToTop(
                                      listingId: widget.productId);
                                  Get.back();
                                  return;
                                }
                              },
                              isFullWidth: true,
                              icon: Ionicons.bag_check_outline,
                              borderColor: whiteColor,
                              bgColor: whiteColor,
                              textIconColor: blackColor,
                            ),
                            CustomButton(
                              text: 'Learn More',
                              onPressed: () => Get.to(
                                () => const BoostInfoScreen(),
                              ),
                              isFullWidth: true,
                              icon: Ionicons.information_outline,
                              borderColor: whiteColor,
                              bgColor: whiteColor,
                              textIconColor: blackColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
