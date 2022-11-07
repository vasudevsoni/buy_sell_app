import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_services.dart';
import 'custom_button.dart';

class MyFavoritesProductsList extends StatefulWidget {
  const MyFavoritesProductsList({super.key});

  @override
  State<MyFavoritesProductsList> createState() =>
      _MyFavoritesProductsListState();
}

class _MyFavoritesProductsListState extends State<MyFavoritesProductsList> {
  final FirebaseServices services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: services.listings
          .orderBy('title', descending: false)
          .where('favorites', arrayContains: services.user!.uid),
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
                'Your favorites will show here.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 13,
              );
            },
            padding: const EdgeInsets.only(
              left: 15,
              top: 10,
              right: 15,
              bottom: 30,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.docs[index];
              var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
              var sellerDetails = services.getUserData(data['sellerUid']);
              final hasMoreReached = snapshot.hasMore &&
                  index + 1 == snapshot.docs.length &&
                  !snapshot.isFetchingMore;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomProductCard(
                    data: data,
                    sellerDetails: sellerDetails,
                    time: time,
                  ),
                  if (hasMoreReached)
                    const SizedBox(
                      height: 10,
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
          );
        }
      },
    );
  }
}
