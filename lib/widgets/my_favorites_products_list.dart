import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';
import '/utils/utils.dart';
import '/services/firebase_services.dart';
import 'custom_button.dart';
import 'custom_button_without_icon.dart';
import 'custom_product_card.dart';

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
    final mainProv = Provider.of<MainProvider>(context, listen: false);
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
          return Column(
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
                  'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FOpen%20Doodles%20-%20Loving.svg?alt=media&token=0091fb33-3f0c-4bca-9e71-c3fa441ec496',
                  semanticsLabel: 'Empty favorites image',
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
                  'You have no favorites yet!',
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
                  'When you favorite a product, it will show here.',
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
                  text: 'Explore Products',
                  onPressed: () => setState(() {
                    mainProv.switchToPage(0);
                  }),
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: AutoSizeText(
                  'Favorites',
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 13,
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
                  var data = snapshot.docs[index];
                  var time =
                      DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
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
