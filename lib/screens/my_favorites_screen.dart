import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';
import '/utils/utils.dart';
import '/services/firebase_services.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_loading_indicator.dart';
import '../widgets/custom_product_card.dart';
import '../widgets/svg_picture.dart';

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
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
        pageSize: 5,
        builder: (context, snapshot, child) {
          if (snapshot.isFetching) {
            return const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Something has gone wrong. Please try again',
                  style: GoogleFonts.interTight(
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
                        'https://res.cloudinary.com/bechdeapp/image/upload/v1674460388/illustrations/favorites_asft5r.svg',
                    fit: BoxFit.contain,
                    semanticsLabel: 'Empty favorites image',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'You have no favorites yet!',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'When you favorite a product, it will show here.',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
                      color: lightBlackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AutoSizeText(
                    'Favorites',
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 6,
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
                    final hasMoreReached = snapshot.hasMore &&
                        index + 1 == snapshot.docs.length &&
                        !snapshot.isFetchingMore;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomProductCard(
                          data: data,
                          time: time,
                        ),
                        if (hasMoreReached)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              CustomButtonWithoutIcon(
                                text: 'Show more',
                                onPressed: () => snapshot.fetchMore(),
                                borderColor: blackColor,
                                bgColor: whiteColor,
                                textIconColor: blackColor,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
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
