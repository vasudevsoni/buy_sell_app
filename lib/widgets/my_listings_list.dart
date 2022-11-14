import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../auth/screens/email_verification_screen.dart';
import '../auth/screens/location_screen.dart';
import '../screens/selling/seller_categories_list_screen.dart';
import '/screens/selling/common/edit_ad_screen.dart';
import '/utils/utils.dart';
import '/screens/product_details_screen.dart';
import '/screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '/services/firebase_services.dart';
import 'custom_button_without_icon.dart';
import 'custom_button.dart';

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
      pageSize: 6,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: SpinKitFadingCircle(
                color: lightBlackColor,
                size: 20,
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: greyColor,
                  ),
                  child: SvgPicture.network(
                    'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FOpen%20Doodles%20-%20Laying%20Down.svg?alt=media&token=314f27c5-1e3b-450b-8f5d-886568e261c3',
                    semanticsLabel: 'Empty products image',
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) => const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: lightBlackColor,
                          size: 20,
                          duration: Duration(milliseconds: 1000),
                        ),
                      ),
                    ),
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
          physics: const BouncingScrollPhysics(),
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
                  var data = snapshot.docs[index];
                  var time = DateFormat.yMMMEd().format(
                      DateTime.fromMillisecondsSinceEpoch(data['postedAt']));
                  var sellerDetails = _services.getUserData(data['sellerUid']);
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
                        CustomButton(
                          text: 'Load More Products',
                          onPressed: () => snapshot.fetchMore(),
                          icon: FontAwesomeIcons.plus,
                          borderColor: blueColor,
                          bgColor: blueColor,
                          textIconColor: whiteColor,
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
  FirebaseServices services = FirebaseServices();
  late DocumentSnapshot sellerDetails;
  bool isLoading = false;

  NumberFormat numberFormat = NumberFormat.compact();

  @override
  void initState() {
    getSellerDetails();
    super.initState();
  }

  getSellerDetails() async {
    setState(() {
      isLoading = true;
    });
    await services.getUserData(widget.data['sellerUid']).then((value) {
      if (mounted) {
        setState(() {
          sellerDetails = value;
        });
      }
    });
    setState(() {
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                const Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
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
                    'Your product will be marked as sold. This action cannot be reversed.',
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                const Text(
                  'Are you sure? 😱',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
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
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  FontAwesomeIcons.circleExclamation,
                                  size: 30,
                                  color: redColor,
                                );
                              },
                              placeholder: (context, url) {
                                return const Icon(
                                  FontAwesomeIcons.solidImage,
                                  size: 30,
                                  color: lightBlackColor,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.data['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: blackColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  AutoSizeText(
                                    priceFormat.format(widget.data['price']),
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: blueColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
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
                                FontAwesomeIcons.eye,
                                size: 16,
                                color: blueColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                numberFormat
                                    .format(widget.data['views'].length),
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
                                FontAwesomeIcons.heart,
                                size: 16,
                                color: pinkColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                numberFormat
                                    .format(widget.data['favorites'].length),
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
                      if (widget.data['isActive'] == false)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: redColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: const Text(
                                'Product is currently unavailable',
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
                      if (widget.data['isActive'] == true)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
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
                    ],
                  ),
                ),
              ),
              if (widget.data['isActive'] == true)
                Positioned(
                  top: 0,
                  right: 0,
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
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40.0,
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
                                  icon: FontAwesomeIcons.solidPenToSquare,
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
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  icon: FontAwesomeIcons.checkDouble,
                                  text: 'Mark as Sold',
                                  onPressed: () {
                                    Get.back();
                                    showMarskasSoldModal();
                                  },
                                  bgColor: whiteColor,
                                  borderColor: blueColor,
                                  textIconColor: blueColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  icon: FontAwesomeIcons.trash,
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
                      FontAwesomeIcons.ellipsisVertical,
                      size: 20,
                    ),
                  ),
                ),
            ],
          );
  }
}
