import 'package:buy_sell_app/promotion/promote_listing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

import '../auth/screens/email_verification_screen.dart';
import '../auth/screens/location_screen.dart';
import '../screens/selling/common/edit_ad_screen.dart';
import '../screens/selling/seller_categories_list_screen.dart';
import '../screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '/utils/utils.dart';
import '/screens/product_details_screen.dart';
import '/services/firebase_services.dart';
import 'custom_button_without_icon.dart';
import 'custom_button.dart';
import 'svg_picture.dart';

class MyListingsList extends StatefulWidget {
  const MyListingsList({super.key});

  @override
  State<MyListingsList> createState() => _MyListingsListState();
}

class _MyListingsListState extends State<MyListingsList> {
  final FirebaseServices _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    onSellButtonClicked() {
      _services.getCurrentUserData().then((value) {
        if (value['location'] != null) {
          Get.to(
            () => const SellerCategoriesListScreen(),
          );
          return;
        }
        Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
        showSnackBar(
          content: 'Please set your location to sell products',
          color: redColor,
        );
      });
    }

    return FirestoreQueryBuilder(
      query: _services.listings
          .orderBy('postedAt', descending: true)
          .where('sellerUid', isEqualTo: _services.user!.uid),
      pageSize: 15,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: SpinKitFadingCircle(
                color: lightBlackColor,
                size: 30,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  height: size.height * 0.3,
                  width: size.width,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: greyColor,
                  ),
                  child: const SVGPictureWidget(
                    url:
                        'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2FHands%20-%20Box.svg?alt=media&token=dd69ad93-939f-48d8-80d3-e06f6b4eee1a',
                    fit: BoxFit.contain,
                    semanticsLabel: 'Empty products image',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'You haven\'t listed any product yet!',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'When you list a product, it will show here.',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: CustomButtonWithoutIcon(
                    text: 'Start Selling',
                    onPressed: !user!.emailVerified &&
                            user!.providerData[0].providerId == 'password'
                        ? () => Get.to(
                              () => const EmailVerificationScreen(),
                            )
                        : onSellButtonClicked,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                child: Text(
                  '${snapshot.docs.length} products',
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
                shrinkWrap: true,
                padding: const EdgeInsets.all(15),
                scrollDirection: Axis.vertical,
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  final data = snapshot.docs[index];
                  final time = DateFormat.yMMMEd().format(
                      DateTime.fromMillisecondsSinceEpoch(data['postedAt']));
                  final sellerDetails =
                      _services.getUserData(data['sellerUid']);
                  final hasMoreReached = snapshot.hasMore &&
                      index + 1 == snapshot.docs.length &&
                      !snapshot.isFetchingMore;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyListingScreenProductCard(
                        data: data,
                        sellerDetails: sellerDetails,
                        time: time,
                      ),
                      if (hasMoreReached)
                        const SizedBox(
                          height: 20,
                        ),
                      if (hasMoreReached)
                        CustomButtonWithoutIcon(
                          text: 'Load More',
                          onPressed: () => snapshot.fetchMore(),
                          borderColor: blackColor,
                          bgColor: whiteColor,
                          textIconColor: blackColor,
                        ),
                    ],
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MyListingScreenProductCard extends StatefulWidget {
  const MyListingScreenProductCard({
    Key? key,
    required this.data,
    required this.sellerDetails,
    required this.time,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final Future<DocumentSnapshot<Object?>> sellerDetails;
  final String time;

  @override
  State<MyListingScreenProductCard> createState() =>
      _MyListingScreenProductCardState();
}

class _MyListingScreenProductCardState
    extends State<MyListingScreenProductCard> {
  final FirebaseServices services = FirebaseServices();
  late DocumentSnapshot sellerDetails;
  bool isLoading = false;
  int selectedValue = 0;

  final NumberFormat numberFormat = NumberFormat.compact();

  @override
  void initState() {
    getSellerDetails();
    super.initState();
  }

  getSellerDetails() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await services.getUserData(widget.data['sellerUid']).then((value) {
      if (mounted) {
        setState(() {
          sellerDetails = value;
        });
      }
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  showMarskasSoldModal() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: transparentColor,
      builder: (context) {
        return SafeArea(
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
              top: 5,
              right: 15,
              bottom: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: fadedColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: Text(
                    'Are you sure?',
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
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greyColor,
                  ),
                  child: const Text(
                    'Your product will be marked as sold and deactivated. This action cannot be reversed.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Yes, Mark as Sold',
                  onPressed: () {
                    services.markAsSold(
                      productId: widget.data.id,
                    );
                    Get.back();
                  },
                  bgColor: whiteColor,
                  borderColor: blueColor,
                  textIconColor: blueColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'No, Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showDeleteModal() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: transparentColor,
      builder: (context) {
        return SafeArea(
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
              top: 5,
              right: 15,
              bottom: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: fadedColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: Text(
                    'Are you sure? 😱',
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
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greyColor,
                  ),
                  child: const Text(
                    'Your product will be permanently deleted.\nAll your chats with buyers for this product will also be deleted.\n\nNote - This action cannot be reversed.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Yes, Delete',
                  onPressed: () {
                    services.deleteListing(
                      listingId: widget.data.id,
                    );
                    Get.back();
                  },
                  bgColor: whiteColor,
                  borderColor: redColor,
                  textIconColor: redColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'No, Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return isLoading
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
        : Stack(
            children: [
              InkWell(
                splashFactory: InkRipple.splashFactory,
                splashColor: fadedColor,
                borderRadius: BorderRadius.circular(10),
                onTap: () => Get.to(
                  () => ProductDetailsScreen(
                    productData: widget.data,
                    sellerData: sellerDetails,
                  ),
                ),
                child: Ink(
                  color: whiteColor,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: widget.data['images'][0],
                              width: size.width * 0.3,
                              height: size.width * 0.3,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Ionicons.alert_circle,
                                  size: 30,
                                  color: redColor,
                                );
                              },
                              placeholder: (context, url) {
                                return const Icon(
                                  Ionicons.image,
                                  size: 30,
                                  color: lightBlackColor,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: size.width * 0.3,
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    priceFormat.format(widget.data['price']),
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: blackColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    widget.data['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: blackColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Posted on - ${widget.time}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: lightBlackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Ionicons.eye_outline,
                                size: 20,
                                color: blueColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Views: ${numberFormat.format(widget.data['views'].length)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: blackColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Ionicons.heart_outline,
                                size: 20,
                                color: redColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Likes: ${numberFormat.format(widget.data['favorites'].length)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: blackColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.data['isActive'] == false &&
                          widget.data['isSold'] == false &&
                          widget.data['isRejected'] == false)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: redColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: const Text(
                                'Product is currently under review',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (widget.data['isActive'] == false &&
                          widget.data['isRejected'] == true)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: redColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: const Text(
                                'Product has been rejected as it goes against our guidelines. Please edit it and make sure all guidelines are followed.',
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (widget.data['isActive'] == true &&
                          widget.data['isRejected'] == false)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            CustomButton(
                              icon: Ionicons.trending_up,
                              text: 'Reach More Buyers',
                              onPressed: () {
                                Get.to(
                                  () => PromoteListingScreen(
                                    productId: widget.data.id,
                                    title: widget.data['title'],
                                    price: widget.data['price'].toDouble(),
                                    imageUrl: widget.data['images'][0],
                                  ),
                                );
                              },
                              bgColor: blueColor,
                              borderColor: blueColor,
                              textIconColor: whiteColor,
                            ),
                          ],
                        ),
                      if (widget.data['isActive'] == true)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: blueColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: const Text(
                                'Product is live',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (widget.data['isSold'] == true)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: redColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: const Text(
                                'Product has been sold',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.data['isActive'] == true ||
                  widget.data['isRejected'] == true)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: transparentColor,
                      builder: (context) {
                        return SafeArea(
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
                              top: 5,
                              right: 15,
                              bottom: 15,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 80.0,
                                    height: 5.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: fadedColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  icon: Ionicons.create_outline,
                                  text: 'Edit Product',
                                  onPressed: () {
                                    Get.back();
                                    widget.data['catName'] == 'Vehicles'
                                        ? Get.to(() => EditVehicleAdScreen(
                                              productData: widget.data,
                                            ))
                                        : Get.to(() => EditAdScreen(
                                              productData: widget.data,
                                            ));
                                  },
                                  bgColor: whiteColor,
                                  borderColor: blackColor,
                                  textIconColor: blackColor,
                                ),
                                if (widget.data['isRejected'] == false)
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomButton(
                                        icon: Ionicons.checkmark_circle,
                                        text: 'Mark as Sold',
                                        onPressed: () {
                                          Get.back();
                                          showMarskasSoldModal();
                                        },
                                        bgColor: whiteColor,
                                        borderColor: blueColor,
                                        textIconColor: blueColor,
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  icon: Ionicons.trash,
                                  text: 'Delete Product',
                                  onPressed: () {
                                    Get.back();
                                    showDeleteModal();
                                  },
                                  bgColor: whiteColor,
                                  borderColor: redColor,
                                  textIconColor: redColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButtonWithoutIcon(
                                  text: 'Cancel',
                                  onPressed: () => Get.back(),
                                  bgColor: whiteColor,
                                  borderColor: greyColor,
                                  textIconColor: blackColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    child: const Icon(
                      Ionicons.ellipsis_vertical,
                      size: 22,
                    ),
                  ),
                ),
            ],
          );
  }
}
