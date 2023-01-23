import 'package:buy_sell_app/widgets/custom_button_without_icon.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../widgets/custom_loading_indicator.dart';
import '../widgets/svg_picture.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/screens/main_screen.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String catName;
  final String subCatName;
  const CategoryProductsScreen({
    super.key,
    required this.catName,
    required this.subCatName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          '$catName > $subCatName',
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: CategoryScreenProductsList(
          catName: catName,
          subCatName: subCatName,
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
    final size = MediaQuery.of(context).size;
    return FirestoreQueryBuilder(
      query: _services.listings
          .orderBy(
            'postedAt',
            descending: true,
          )
          .where('catName', isEqualTo: widget.catName)
          .where('subCat', isEqualTo: widget.subCatName)
          .where('isActive', isEqualTo: true),
      pageSize: 15,
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
          return Padding(
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
                        'https://res.cloudinary.com/bechdeapp/image/upload/v1674460581/illustrations/empty_qjocex.svg',
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
                    'No products in this category',
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
                  height: 15,
                ),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () =>
                      Get.offAll(() => const MainScreen(selectedIndex: 0)),
                  icon: Ionicons.home,
                  borderColor: blueColor,
                  bgColor: blueColor,
                  textIconColor: whiteColor,
                ),
              ],
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
                  var data = snapshot.docs[index];
                  var time =
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
                physics: const ClampingScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }
}
