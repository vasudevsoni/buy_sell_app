import 'package:buy_sell_app/promotion/promotion_api.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/utils.dart';
import '../widgets/custom_button_without_icon.dart';

class PromoteListingScreen extends StatefulWidget {
  final String productId;
  final String imageUrl;
  final String title;
  final double price;
  const PromoteListingScreen({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.title,
    required this.price,
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
    fetchOffers();
    super.initState();
  }

  Future fetchOffers() async {
    setState(() {
      isLoading = true;
    });
    await PromotionApi.init();
    final offerings = await PromotionApi.fetchOffers();
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
        title: const Text(
          'Promote your product',
          style: TextStyle(
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
                child: SpinKitFadingCircle(
                  color: lightBlackColor,
                  size: 30,
                  duration: Duration(milliseconds: 1000),
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: blueColor,
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
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    Ionicons.alert_circle,
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
                                priceFormat.format(widget.price),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: whiteColor,
                                ),
                              ),
                              Text(
                                widget.title,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Available Offers',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: InkWell(
                      splashFactory: InkRipple.splashFactory,
                      splashColor: greyColor,
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        showModalBottomSheet<dynamic>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: transparentColor,
                          builder: (context) {
                            return SafeArea(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    color: whiteColor,
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 5,
                                    bottom: 15,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 80.0,
                                          height: 5.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: fadedColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Center(
                                        child: Text(
                                          'Boost to Top Example',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CachedNetworkImage(
                                        imageUrl:
                                            'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2Fboost-to-top-gif.gif?alt=media&token=47bde363-ba46-4263-95ca-692052662b4c',
                                        height: size.height * 0.7,
                                        width: size.width,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomButtonWithoutIcon(
                                        text: 'Close',
                                        onPressed: () => Get.back(),
                                        bgColor: whiteColor,
                                        borderColor: greyColor,
                                        textIconColor: blackColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Ink(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product!.title.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: whiteColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      product!.priceString.toString(),
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
                                    Ionicons.checkmark,
                                    color: whiteColor,
                                    size: 16,
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
                                    Ionicons.checkmark,
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
                                    Ionicons.checkmark,
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
                              const SizedBox(
                                height: 15,
                              ),
                              const Center(
                                child: Text(
                                  'View Example',
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: greyColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
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
                                icon: Ionicons.bag_check,
                                borderColor: whiteColor,
                                bgColor: whiteColor,
                                textIconColor: blueColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
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
