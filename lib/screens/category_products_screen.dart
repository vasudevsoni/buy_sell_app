import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_services.dart';
import '../utils/utils.dart';

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
  final FirebaseServices _services = FirebaseServices();
  bool isLocationEmpty = false;
  String city = '';

  @override
  void initState() {
    _services.getCurrentUserData().then((value) {
      if (value['location'] == null) {
        setState(() {
          isLocationEmpty = true;
        });
      } else {
        setState(() {
          city = value['location']['city'];
          isLocationEmpty = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          '${widget.catName} > ${widget.subCatName}',
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
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
                    isLocationEmpty ? 'Results' : 'Results in $city',
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
                  isLocationEmpty: isLocationEmpty,
                  city: city,
                ),
              ],
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
  final bool isLocationEmpty;
  final String city;
  const CategoryScreenProductsList({
    super.key,
    required this.catName,
    required this.subCatName,
    required this.isLocationEmpty,
    required this.city,
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
    return FirestoreQueryBuilder(
      query: widget.isLocationEmpty
          ? _services.listings
              .orderBy(
                'postedAt',
                descending: true,
              )
              .where('catName', isEqualTo: widget.catName)
              .where('subCat', isEqualTo: widget.subCatName)
              .where('isActive', isEqualTo: true)
          : _services.listings
              .orderBy(
                'postedAt',
                descending: true,
              )
              .where('catName', isEqualTo: widget.catName)
              .where('subCat', isEqualTo: widget.subCatName)
              .where('isActive', isEqualTo: true)
              .where('location.city', isEqualTo: widget.city),
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
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.heartCrack,
                    size: 60,
                    color: pinkColor,
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
                  const SizedBox(
                    height: 15,
                  ),
                  CustomButton(
                    text: 'Go to Home',
                    onPressed: () =>
                        Get.offAll(() => const MainScreen(selectedIndex: 0)),
                    icon: FontAwesomeIcons.house,
                    borderColor: blackColor,
                    bgColor: blackColor,
                    textIconColor: whiteColor,
                  ),
                ],
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
              var sellerDetails = _services.getUserData(data['sellerUid']);
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
            physics: const BouncingScrollPhysics(),
          );
        }
      },
    );
  }
}
