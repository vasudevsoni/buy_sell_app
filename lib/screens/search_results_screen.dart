import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../services/firebase_services.dart';
import '../utils/utils.dart';
import '../widgets/custom_product_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final FirebaseServices _services = FirebaseServices();
  var priceFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '₹ ',
    name: '',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Text(
            widget.query,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              FirestoreQueryBuilder(
                query: _services.listings
                    .where('searchQueries', arrayContains: widget.query)
                    .orderBy('postedAt', descending: true),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.heart_slash4,
                              size: 60,
                              color: redColor,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'No products here',
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
                      padding: const EdgeInsets.all(15),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.docs[index];
                        var time = DateTime.fromMillisecondsSinceEpoch(
                            data['postedAt']);
                        var sellerDetails =
                            _services.getUserData(data['sellerUid']);
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
