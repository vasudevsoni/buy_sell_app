import 'package:buy_sell_app/promotion/promotion_api.dart';
import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../provider/providers.dart';
import '../utils/utils.dart';
import '../widgets/custom_loading_indicator.dart';

class RemoveAdsScreen extends StatefulWidget {
  const RemoveAdsScreen({super.key});

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  Package? package;
  StoreProduct? product;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRemoveAdOffer();
  }

  Future<void> fetchRemoveAdOffer() async {
    setState(() {
      isLoading = true;
    });
    await PromotionApi.init();
    final offering =
        await PromotionApi.fetchRemoveAdsOffer(RemoveAds.idRemoveAds);
    if (mounted) {
      setState(() {
        package = offering.availablePackages.first;
        product = package!.storeProduct;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainProv = Provider.of<AppNavigationProvider>(context);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Remove ads',
          style: GoogleFonts.sora(
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
                  const SizedBox(
                    height: 15,
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
                                    style: GoogleFonts.sora(
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
                                        style: GoogleFonts.sora(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: whiteColor,
                                        ),
                                      ),
                                      Text(
                                        '₹500.00',
                                        textAlign: TextAlign.end,
                                        style: GoogleFonts.sora(
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
                                  Ionicons.close_circle_outline,
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
                                    style: GoogleFonts.sora(
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
                                  try {
                                    await users.doc(user!.uid).update({
                                      'adsRemoved': true,
                                    });
                                    mainProv.removeAds();
                                    showSnackBar(
                                      content:
                                          'All ads removed. Thank you for your purchase.',
                                      color: blueColor,
                                    );
                                  } on FirebaseException {
                                    showSnackBar(
                                      content:
                                          'Something has gone wrong. Please try again',
                                      color: redColor,
                                    );
                                  }
                                  Get.offAll(
                                    () => const MainScreen(selectedIndex: 0),
                                  );
                                  return;
                                }
                              },
                              isFullWidth: true,
                              icon: Ionicons.bag_check_outline,
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
