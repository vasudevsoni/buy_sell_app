import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../widgets/custom_button_without_icon.dart';
import '../widgets/svg_picture.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/widgets/custom_product_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: Text(
            widget.query,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: FirestoreQueryBuilder(
        query: _services.listings
            .where('searchQueries', arrayContains: widget.query)
            .where('isActive', isEqualTo: true)
            .orderBy('postedAt', descending: true),
        pageSize: 15,
        builder: (context, snapshot, child) {
          if (snapshot.isFetching) {
            return const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
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
              child: Padding(
                padding: const EdgeInsets.all(15),
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
                            'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fempty.svg?alt=media&token=6a2d5433-d3df-4338-8646-e709a9247d97',
                        fit: BoxFit.contain,
                        semanticsLabel: 'Empty search image',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'No results found',
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
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 15,
                  ),
                  child: Text(
                    'Results',
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 10,
                    right: 15,
                    bottom: 15,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.docs[index];
                    final time =
                        DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
                    final sellerDetails =
                        _services.getUserData(data['sellerUid']);
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
      ),
    );
  }
}
