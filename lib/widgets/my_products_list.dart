import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/product_details_screen.dart';
import '../screens/selling/edit_vehicle_ad_screen.dart';
import '../services/firebase_services.dart';

class MyProductsList extends StatefulWidget {
  const MyProductsList({super.key});

  @override
  State<MyProductsList> createState() => _MyProductsListState();
}

class _MyProductsListState extends State<MyProductsList> {
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
          .orderBy('postedAt', descending: false)
          .where('sellerUid', isEqualTo: _services.user!.uid),
      pageSize: 6,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
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
                'Some error occurred. Please try again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
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
          return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.docs[index];
              var time = DateFormat.yMMMEd().format(
                  DateTime.fromMillisecondsSinceEpoch(data['postedAt']));
              var sellerDetails = _services.getUserData(data['sellerUid']);
              final hasEndReached = snapshot.hasMore &&
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
                  if (hasEndReached)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromHeight(70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          snapshot.fetchMore();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Load more',
                              style: GoogleFonts.poppins(
                                color: blueColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              Iconsax.arrow_square_down4,
                              size: 15,
                              color: blueColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            physics: const NeverScrollableScrollPhysics(),
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

  @override
  void initState() {
    getSellerDetails();
    super.initState();
  }

  getSellerDetails() {
    services.getUserData(widget.data['sellerUid']).then((value) {
      if (mounted) {
        setState(() {
          sellerDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  child: ProductDetailsScreen(
                    productData: widget.data,
                    sellerData: sellerDetails,
                  ),
                  type: PageTransitionType.rightToLeftWithFade,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: widget.data['images'][0],
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.width * 0.25,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Iconsax.warning_24,
                              size: 30,
                              color: redColor,
                            );
                          },
                          placeholder: (context, url) {
                            return const Icon(
                              Iconsax.image4,
                              size: 30,
                              color: lightBlackColor,
                            );
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        padding: const EdgeInsets.only(
                          left: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              widget.priceFormat.format(widget.data['price']),
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: blueColor,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Posted on - ${widget.time}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: lightBlackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Favorited',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        widget.data['favorites'].length.toString(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: redColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Edit listing',
                    onPressed: () {
                      widget.data['catName'] == 'Vehicles'
                          ? Navigator.of(context).push(
                              PageTransition(
                                child: EditVehicleAdScreen(
                                  productData: widget.data,
                                ),
                                type: PageTransitionType.rightToLeftWithFade,
                              ),
                            )
                          : null;
                    },
                    icon: Iconsax.edit4,
                    bgColor: blackColor,
                    borderColor: blackColor,
                    textIconColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
