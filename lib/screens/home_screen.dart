import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/search_field_screen.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
// import 'package:geocode/geocode.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

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
  CarouselController controller = CarouselController();
  final FirebaseServices _services = FirebaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  String defaultAddress = 'India';

  //TODO: video 5 and 9 for location
  // Future<String> getAddress() async {
  //   GeoCode geoCode = GeoCode();
  //   try {
  //     Address getAddress = await geoCode.reverseGeocoding(
  //       latitude: widget.locationData!.latitude as double,
  //       longitude: widget.locationData!.longitude as double,
  //     );
  //     setState(() {
  //       defaultAddress = getAddress.toString();
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //   return defaultAddress;
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    //TODO: getAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(SearchFieldScreen.routeName);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                      Iconsax.search_normal_14,
                      size: 20,
                    ),
                  ),
                ),
              ],
              automaticallyImplyLeading: false,
              elevation: 0.2,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                'BestDeal',
                style: GoogleFonts.poppins(
                  color: blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              leading: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Icon(
                  Iconsax.ghost4,
                  size: 20,
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: AutoSizeText(
                            'Browse Categories',
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context)
                                .pushNamed(CategoriesListScreen.routeName);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'See all',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: blueColor,
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              const Icon(
                                Iconsax.arrow_circle_right4,
                                size: 13,
                                color: blueColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<QuerySnapshot>(
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
                              'Some error occurred. Please try again',
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
                        carouselController: controller,
                        itemCount: 6,
                        itemBuilder: (context, index, realIndex) {
                          var doc = snapshot.data!.docs[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  child: SubCategoriesListScreen(doc: doc),
                                  type: PageTransitionType.rightToLeftWithFade,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: greyColor,
                              ),
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: doc['image'],
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      errorWidget: (context, url, error) {
                                        return const Icon(
                                          Iconsax.warning_24,
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
                                        color: Colors.white,
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
                          );
                        },
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.2,
                          viewportFraction: 0.9,
                          pageSnapping: true,
                          enlargeCenterPage: false,
                          autoPlayInterval: const Duration(seconds: 4),
                          enableInfiniteScroll: true,
                          scrollDirection: Axis.horizontal,
                          scrollPhysics: const BouncingScrollPhysics(),
                          autoPlay: false,
                          pauseAutoPlayOnManualNavigate: true,
                          pauseAutoPlayOnTouch: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 15,
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
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const HomeScreenProductsList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenProductsList extends StatefulWidget {
  const HomeScreenProductsList({super.key});

  @override
  State<HomeScreenProductsList> createState() => _HomeScreenProductsListState();
}

class _HomeScreenProductsListState extends State<HomeScreenProductsList> {
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
      query: _services.listings.orderBy(
        'postedAt',
        descending: true,
      ),
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
                    TextButton(
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
