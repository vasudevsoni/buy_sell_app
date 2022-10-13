import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/firebase_services.dart';

class MyAdsScreenProductsList extends StatefulWidget {
  const MyAdsScreenProductsList({super.key});

  @override
  State<MyAdsScreenProductsList> createState() =>
      _MyAdsScreenProductsListState();
}

class _MyAdsScreenProductsListState extends State<MyAdsScreenProductsList> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );

    return FutureBuilder<QuerySnapshot>(
      future: _services.listings
          .orderBy('postedAt', descending: true)
          .where('sellerUid', isEqualTo: _services.user!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Some error occurred. Please try again');
        } else if (snapshot.hasData && snapshot.data!.size == 0) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.heartCrack,
                    size: 60,
                    color: redColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Your products will show here.\nStart by clicking the + button below.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCube(
                color: blueColor,
                size: 30,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);

            return Column(
              children: [
                Stack(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 1,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: data['images'][0],
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    FontAwesomeIcons.triangleExclamation,
                                    size: 20,
                                    color: redColor,
                                  );
                                },
                                placeholder: (context, url) {
                                  return const Center(
                                    child: SpinKitFadingCube(
                                      color: blueColor,
                                      size: 30,
                                      duration: Duration(milliseconds: 1000),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.60,
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    priceFormat.format(data['price']),
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
                                    data['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: lightBlackColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    timeago.format(time),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      color: blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 0,
                  color: fadedColor,
                  indent: 15,
                  endIndent: 15,
                )
              ],
            );
          },
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}
