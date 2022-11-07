import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/auth/screens/location_screen.dart';
import 'package:buy_sell_app/screens/search_field_screen.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

import '../widgets/custom_button.dart';
import 'categories/sub_categories_list_screen.dart';
import '../services/firebase_services.dart';
import 'categories/categories_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  final LocationData? locationData;
  const HomeScreen({
    super.key,
    this.locationData,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseServices _services = FirebaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  String area = '';
  String city = '';
  String state = '';
  String country = '';
  bool isLocationEmpty = false;

  getAddressToUI() async {
    await _services.getCurrentUserData().then((value) {
      if (mounted) {
        setState(() {
          area = value['location']['area'];
          city = value['location']['city'];
          state = value['location']['state'];
          country = value['location']['country'];
        });
      }
    });
  }

  getEmptyLocationUI() async {
    setState(() {
      isLocationEmpty = true;
    });
  }

  @override
  void initState() {
    _services.getCurrentUserData().then((value) {
      if (value['location'] != null) {
        getAddressToUI();
      } else {
        getEmptyLocationUI();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              elevation: 0.5,
              backgroundColor: whiteColor,
              pinned: true,
              // floating: true,
              // snap: true,
              iconTheme: const IconThemeData(color: blackColor),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    FontAwesomeIcons.twitter,
                    color: blueColor,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // const Icon(
                            //   FontAwesomeIcons.locationDot,
                            //   color: blueColor,
                            //   size: 20,
                            // ),
                            // const SizedBox(
                            //   width: 3,
                            // ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () => Get.to(
                                  () => const LocationScreen(
                                    isOpenedFromSellButton: false,
                                  ),
                                ),
                                child: AutoSizeText(
                                  isLocationEmpty == true
                                      ? 'Set location'
                                      : area == ''
                                          ? city
                                          : area,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            const Icon(
                              FontAwesomeIcons.caretDown,
                              size: 15,
                              color: blackColor,
                            ),
                          ],
                        ),
                        if (isLocationEmpty == false)
                          Text(
                            '$city, $state, $country',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: fadedColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.toNamed(SearchFieldScreen.routeName),
                    child: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: blackColor,
                      size: 20,
                    ),
                  )
                ],
              ),
            ),
          ],
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Browse Categories',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Get.toNamed(CategoriesListScreen.routeName),
                        child: Text(
                          'See all',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: blueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder<QuerySnapshot>(
                    future: _services.categories
                        .orderBy('sortId', descending: false)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
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
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                      }
                      return CarouselSlider.builder(
                        itemCount: 6,
                        options: CarouselOptions(
                          viewportFraction: 0.85,
                          pageSnapping: true,
                          height: MediaQuery.of(context).size.height,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: true,
                          reverse: false,
                          scrollDirection: Axis.horizontal,
                          scrollPhysics: const BouncingScrollPhysics(),
                        ),
                        itemBuilder: (context, index, realIndex) {
                          var doc = snapshot.data!.docs[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Get.to(
                              () => SubCategoriesListScreen(doc: doc),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: greyColor,
                              ),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: doc['image'],
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        errorWidget: (context, url, error) {
                                          return const Icon(
                                            FontAwesomeIcons.circleExclamation,
                                            size: 30,
                                            color: redColor,
                                          );
                                        },
                                        placeholder: (context, url) {
                                          return const Center(
                                            child: SpinKitFadingCube(
                                              color: lightBlackColor,
                                              size: 30,
                                              duration:
                                                  Duration(milliseconds: 1000),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        doc['catName'],
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 35,
                                          color: whiteColor,
                                          shadows: <Shadow>[
                                            const Shadow(
                                              offset: Offset(0, 2),
                                              blurRadius: 10.0,
                                              color: lightBlackColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AutoSizeText(
                    'Latest Products',
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                HomeScreenProductsList(
                  city: city,
                  isLocationEmpty: isLocationEmpty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenProductsList extends StatefulWidget {
  final String city;
  final bool isLocationEmpty;
  const HomeScreenProductsList({
    super.key,
    required this.city,
    required this.isLocationEmpty,
  });

  @override
  State<HomeScreenProductsList> createState() => _HomeScreenProductsListState();
}

class _HomeScreenProductsListState extends State<HomeScreenProductsList> {
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
              .where('isActive', isEqualTo: true)
          : _services.listings
              .orderBy(
                'postedAt',
                descending: true,
              )
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
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 13,
              );
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.only(
              left: 15,
              top: 10,
              right: 15,
              bottom: 30,
            ),
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
            physics: const NeverScrollableScrollPhysics(),
          );
        }
      },
    );
  }
}
