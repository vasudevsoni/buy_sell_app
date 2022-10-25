import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import '../services/firebase_services.dart';
import '../utils/utils.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String catName;
  final String subCatName;
  const CategoryProductsScreen({
    super.key,
    required this.catName,
    required this.subCatName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              elevation: 0.2,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              title: Text(
                '${widget.catName} > ${widget.subCatName}',
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            )
          ],
          body: Scrollbar(
            interactive: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 15,
                    ),
                    child: Text(
                      'Results',
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  CategoryScreenProductsList(
                    catName: widget.catName,
                    subCatName: widget.subCatName,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryScreenProductsList extends StatefulWidget {
  final String catName;
  final String subCatName;
  const CategoryScreenProductsList({
    super.key,
    required this.catName,
    required this.subCatName,
  });

  @override
  State<CategoryScreenProductsList> createState() =>
      _CategoryScreenProductsListState();
}

class _CategoryScreenProductsListState
    extends State<CategoryScreenProductsList> {
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
          .orderBy(
            'postedAt',
            descending: true,
          )
          .where('catName', isEqualTo: widget.catName)
          .where('subCat', isEqualTo: widget.subCatName),
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
                    'No products in this category.',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(MainScreen.routeName);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to Home',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: blueColor,
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        const Icon(
                          Iconsax.home5,
                          size: 13,
                          color: blueColor,
                        ),
                      ],
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
              var sellerDetails = _services.getUserData(data['sellerUid']);
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
            physics: const BouncingScrollPhysics(),
          );
        }
      },
    );
  }
}
