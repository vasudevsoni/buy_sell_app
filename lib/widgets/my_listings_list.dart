import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

import '../auth/screens/email_verification_screen.dart';
import '../auth/screens/location_screen.dart';
import '../promotion/promote_listing_screen.dart';
import '../screens/selling/common/edit_ad_screen.dart';
import '../screens/selling/jobs/edit_job_post_screen.dart';
import '../screens/selling/seller_categories_list_screen.dart';
import '../screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '/utils/utils.dart';
import '/screens/product_details_screen.dart';
import '/services/firebase_services.dart';
import 'custom_button_without_icon.dart';
import 'custom_button.dart';
import 'custom_loading_indicator.dart';
import 'svg_picture.dart';

class MyListingsList extends StatelessWidget {
  const MyListingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseServices services = FirebaseServices();
    final User? user = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;

    void onSellButtonClicked() async {
      final value = await services.getCurrentUserData();
      if (value['location'] != null) {
        Get.to(() => const SellerCategoriesListScreen());
      } else {
        Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
        showSnackBar(
          content: 'Please set your location to sell products',
          color: redColor,
        );
      }
    }

    return FirestoreQueryBuilder(
      query: services.listings
          .orderBy('postedAt', descending: true)
          .where('sellerUid', isEqualTo: services.user!.uid),
      pageSize: 10,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: CustomLoadingIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: GoogleFonts.interTight(
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
                        'https://res.cloudinary.com/bechdeapp/image/upload/v1674460308/illustrations/Hands_-_Box_c06yok.svg',
                    fit: BoxFit.contain,
                    semanticsLabel: 'Empty products image',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'You haven\'t listed any product yet!',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'When you list a product, it will show here.',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
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
                            user.providerData[0].providerId == 'password'
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
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                child: Text(
                  '${snapshot.docs.length} products',
                  maxLines: 1,
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 15,
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
                  final sellerDetails = services.getUserData(data['sellerUid']);
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
                          text: 'Show more',
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
    super.initState();
    getSellerDetails();
  }

  Future<void> getSellerDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    final value = await services.getUserData(widget.data['sellerUid']);
    setState(() {
      sellerDetails = value;
      isLoading = false;
    });
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
                Center(
                  child: Text(
                    'Where did you sell this item?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  text: 'On BechDe',
                  onPressed: () {
                    services.markAsSold(
                      productId: widget.data.id,
                      isSoldOnBechDe: true,
                    );
                    Get.back();
                  },
                  icon: Ionicons.checkmark_circle_outline,
                  isFullWidth: true,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
                CustomButton(
                  text: 'Outside of BechDe',
                  onPressed: () {
                    services.markAsSold(
                      productId: widget.data.id,
                      isSoldOnBechDe: false,
                    );
                    Get.back();
                  },
                  icon: Ionicons.arrow_up,
                  isFullWidth: true,
                  bgColor: greyColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
                CustomButton(
                  text: 'Cancel',
                  onPressed: () => Get.back(),
                  icon: Ionicons.close,
                  isFullWidth: true,
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: CustomButtonWithoutIcon(
                //         text: 'Cancel',
                //         onPressed: () => Get.back(),
                //         bgColor: whiteColor,
                //         borderColor: greyColor,
                //         textIconColor: blackColor,
                //       ),
                //     ),
                //     const SizedBox(
                //       width: 5,
                //     ),
                //     Expanded(
                //       child: CustomButtonWithoutIcon(
                //         text: 'Mark as Sold',
                //         onPressed: () {
                //           services.markAsSold(
                //             productId: widget.data.id,
                //           );
                //           Get.back();
                //         },
                //         bgColor: blueColor,
                //         borderColor: blueColor,
                //         textIconColor: whiteColor,
                //       ),
                //     ),
                //   ],
                // ),
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
                Center(
                  child: Text(
                    'Are you sure? 😱',
                    style: GoogleFonts.interTight(
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
                    color: whiteColor,
                    border: greyBorder,
                  ),
                  child: Text(
                    'Your product will be permanently deleted.\nAll your chats with buyers for this listing will also be deleted.\n\nNote - This action cannot be reversed.',
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        bgColor: whiteColor,
                        borderColor: greyColor,
                        textIconColor: blackColor,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Delete',
                        onPressed: () {
                          services.deleteListing(
                            listingId: widget.data.id,
                          );
                          Get.back();
                        },
                        bgColor: redColor,
                        borderColor: redColor,
                        textIconColor: whiteColor,
                      ),
                    ),
                  ],
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
              child: CustomLoadingIndicator(),
            ),
          )
        : Stack(
            children: [
              InkWell(
                splashFactory: InkRipple.splashFactory,
                splashColor: transparentColor,
                borderRadius: BorderRadius.circular(10),
                onTap: () => Get.to(
                  () => ProductDetailsScreen(
                    productData: widget.data,
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: whiteColor,
                    border: greyBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.3,
                              height: size.width * 0.3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: CachedNetworkImage(
                                  imageUrl: widget.data['images'][0],
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  memCacheHeight: (size.height * 0.3).round(),
                                  errorWidget: (context, url, error) {
                                    return const Icon(
                                      Ionicons.alert_circle_outline,
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
                            ),
                            Expanded(
                              child: Container(
                                height: size.width * 0.3,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    widget.data['catName'] == 'Jobs'
                                        ? AutoSizeText(
                                            '${priceFormat.format(widget.data['salaryFrom'])} - ${priceFormat.format(widget.data['salaryTo'])}',
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w800,
                                              color: blackColor,
                                              fontSize: 16,
                                            ),
                                          )
                                        : AutoSizeText(
                                            priceFormat
                                                .format(widget.data['price']),
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w800,
                                              color: blackColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    if (widget.data['catName'] == 'Jobs')
                                      Column(
                                        children: [
                                          AutoSizeText(
                                            'Salary Period - ${widget.data['salaryPeriod']}',
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w500,
                                              color: blackColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                        ],
                                      ),
                                    widget.data['catName'] == 'Jobs'
                                        ? Text(
                                            widget.data['title'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w500,
                                              color: blackColor,
                                              fontSize: 15,
                                            ),
                                          )
                                        : Text(
                                            widget.data['title'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w500,
                                              color: blackColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                    const Spacer(),
                                    Text(
                                      widget.time,
                                      maxLines: 1,
                                      style: GoogleFonts.interTight(
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
                                  style: GoogleFonts.interTight(
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
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Ionicons.finger_print,
                              size: 20,
                              color: blackColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Product ID: ${widget.data.id}',
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: lightBlackColor,
                              ),
                            ),
                          ],
                        ),
                        if (widget.data['isActive'] == false &&
                            widget.data['isSold'] == false &&
                            widget.data['isRejected'] == false)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Chip(
                                  backgroundColor: blackColor,
                                  label: AutoSizeText(
                                    'UNDER REVIEW. Usually takes up to 24 hours to complete. May take longer than 24 hours during weekends or holidays when our team is not fully staffed.',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (widget.data['isActive'] == false &&
                            widget.data['isRejected'] == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Chip(
                                  backgroundColor: redColor,
                                  label: Text(
                                    'REJECTED. Please edit and submit again\nNote: Rejected listings are deleted after a few days',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (widget.data['isActive'] == true &&
                            widget.data['isRejected'] == false &&
                            widget.data['isSold'] == false)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Chip(
                                  backgroundColor: greenColor,
                                  label: Text(
                                    'ACTIVE',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (widget.data['isSold'] == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Chip(
                                  backgroundColor: blueColor,
                                  label: Text(
                                    'SOLD',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: whiteColor,
                                    ),
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
              if ((widget.data['isActive'] == true &&
                      widget.data['isSold'] == false) ||
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
                                if (widget.data['isRejected'] == false)
                                  CustomButton(
                                    icon: Ionicons.trending_up,
                                    text: 'Promote Listing',
                                    onPressed: () => Get.to(
                                      () => PromoteListingScreen(
                                        productId: widget.data.id,
                                        title: widget.data['title'],
                                        imageUrl: widget.data['images'][0],
                                      ),
                                    ),
                                    isFullWidth: true,
                                    bgColor: blueColor,
                                    borderColor: blueColor,
                                    textIconColor: whiteColor,
                                  ),
                                CustomButton(
                                  icon: Ionicons.create_outline,
                                  text: 'Edit Product',
                                  onPressed: () {
                                    Get.back();
                                    if (widget.data['catName'] == 'Vehicles') {
                                      Get.to(
                                        () => EditVehicleAdScreen(
                                          productData: widget.data,
                                        ),
                                      );
                                      return;
                                    } else if (widget.data['catName'] ==
                                        'Jobs') {
                                      Get.to(
                                        () => EditJobAdScreen(
                                          productData: widget.data,
                                        ),
                                      );
                                      return;
                                    }
                                    Get.to(
                                      () => EditAdScreen(
                                        productData: widget.data,
                                      ),
                                    );
                                  },
                                  isFullWidth: true,
                                  bgColor: whiteColor,
                                  borderColor: blackColor,
                                  textIconColor: blackColor,
                                ),
                                if (widget.data['isRejected'] == false)
                                  CustomButton(
                                    icon: Ionicons.checkmark_circle_outline,
                                    text: 'Mark as Sold',
                                    onPressed: () {
                                      Get.back();
                                      showMarskasSoldModal();
                                    },
                                    isFullWidth: true,
                                    bgColor: whiteColor,
                                    borderColor: blueColor,
                                    textIconColor: blueColor,
                                  ),
                                CustomButton(
                                  icon: Ionicons.trash_outline,
                                  text: 'Delete Product',
                                  onPressed: () {
                                    Get.back();
                                    showDeleteModal();
                                  },
                                  isFullWidth: true,
                                  bgColor: whiteColor,
                                  borderColor: redColor,
                                  textIconColor: redColor,
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
