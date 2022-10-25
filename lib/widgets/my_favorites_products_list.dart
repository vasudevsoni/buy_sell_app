import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../services/firebase_services.dart';

class MyFavoritesProductsList extends StatelessWidget {
  MyFavoritesProductsList({super.key});

  final FirebaseServices services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );

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
                'Some error occurred. Please try again',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.heart4,
                    size: 60,
                    color: redColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
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
                ],
              ),
            ),
          );
        } else {
          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            padding: const EdgeInsets.only(
              left: 10,
              top: 0,
              right: 10,
              bottom: 30,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.docs[index];
              var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
              var sellerDetails = services.getUserData(data['sellerUid']);
              final hasEndReached = snapshot.hasMore &&
                  index + 1 == snapshot.docs.length &&
                  !snapshot.isFetchingMore;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomProductCard(
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
