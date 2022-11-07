import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/selling/common/edit_ad_screen.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

import '../screens/product_details_screen.dart';
import '../screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '../services/firebase_services.dart';
import 'custom_button_without_icon.dart';

class MyListingsList extends StatefulWidget {
  const MyListingsList({super.key});

  @override
  State<MyListingsList> createState() => _MyListingsListState();
}

class _MyListingsListState extends State<MyListingsList> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );

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
              child: SpinKitFadingCube(
                color: lightBlackColor,
                size: 20,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Your listings will show here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                child: Text(
                  '${snapshot.docs.length} products',
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
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
                        priceFormat: priceFormat,
                        time: time,
                      ),
                      if (hasMoreReached)
                        const SizedBox(
                          height: 20,
                        ),
                      if (hasMoreReached)
                        CustomButton(
                          text: 'Load more',
                          onPressed: () => snapshot.fetchMore(),
                          icon: FontAwesomeIcons.chevronDown,
                          borderColor: blackColor,
                          bgColor: blackColor,
                          textIconColor: whiteColor,
                        ),
                    ],
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          );
        }
      },
    );
  }
}

class MyListingScreenProductCard extends StatefulWidget {
  const MyListingScreenProductCard({
    Key? key,
    required this.data,
    required this.sellerDetails,
    required this.priceFormat,
    required this.time,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final Future<DocumentSnapshot<Object?>> sellerDetails;
  final NumberFormat priceFormat;
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

  showDeleteModal() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: ShapeDecoration(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: whiteColor,
            ),
            margin: const EdgeInsets.all(15),
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
                Text(
                  'Are you sure? 😱',
                  style: GoogleFonts.poppins(
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
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: greyColor,
                  ),
                  child: Text(
                    'Your listing will be permanently deleted.\nAll your chats with buyers for this product will also be deleted.\n\nNote - This action cannot be reversed.',
                    style: GoogleFonts.poppins(
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
                  onPressed: () async {
                    await services.deleteListing(
                      listingId: widget.data['postedAt'],
                      context: context,
                    );
                    Get.back();
                  },
                  bgColor: redColor,
                  borderColor: redColor,
                  textIconColor: whiteColor,
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
              child: SpinKitFadingCube(
                color: lightBlackColor,
                size: 30,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          )
        : Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.to(
                  () => ProductDetailsScreen(
                    productData: widget.data,
                    sellerData: sellerDetails,
                  ),
                ),
                child: Container(
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
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      color: blackColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  AutoSizeText(
                                    widget.priceFormat
                                        .format(widget.data['price']),
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: blueColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Posted on - ${widget.time}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.5,
                                      color: lightBlackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                              decoration: ShapeDecoration(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: redColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: Text(
                                'This item is currently unavailable',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: GoogleFonts.poppins(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.eye,
                                      size: 22,
                                      color: blueColor,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      numberFormat
                                          .format(widget.data['views'].length),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.heart,
                                      size: 22,
                                      color: pinkColor,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      numberFormat.format(
                                          widget.data['favorites'].length),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: ShapeDecoration(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: blueColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: Text(
                                'Listing is live',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: GoogleFonts.poppins(
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
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return SafeArea(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              color: whiteColor,
                            ),
                            margin: const EdgeInsets.all(15),
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
                                  text: 'Edit item',
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
                                  bgColor: greyColor,
                                  borderColor: greyColor,
                                  textIconColor: blackColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  icon: FontAwesomeIcons.checkDouble,
                                  text: 'Mark as sold',
                                  onPressed: () => Get.back(),
                                  bgColor: greyColor,
                                  borderColor: greyColor,
                                  textIconColor: blackColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  icon: FontAwesomeIcons.trash,
                                  text: 'Delete item',
                                  onPressed: () {
                                    Get.back();
                                    showDeleteModal();
                                  },
                                  bgColor: greyColor,
                                  borderColor: greyColor,
                                  textIconColor: blackColor,
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
