import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';
import '/utils/utils.dart';
import '/services/firebase_services.dart';
import 'custom_button_without_icon.dart';
import 'custom_product_card.dart';
import 'svg_picture.dart';

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
    final size = MediaQuery.of(context).size;
    final mainProv = Provider.of<MainProvider>(context, listen: false);

    return SafeArea(
      child: FirestoreQueryBuilder(
        query: services.listings
            .orderBy('title', descending: false)
            .where('favorites', arrayContains: services.user!.uid),
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
            return Column(
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
                        'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Ffavorites.svg?alt=media&token=6d0db557-0c12-46ee-8019-77b3b3b1e446',
                    fit: BoxFit.contain,
                    semanticsLabel: 'Empty favorites image',
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
                    onPressed: () => mainProv.switchToPage(0),
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
                        services.getUserData(data['sellerUid']);
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
