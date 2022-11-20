import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:location/location.dart';

import '../widgets/custom_button_without_icon.dart';
import '/widgets/custom_button.dart';
import '/services/firebase_services.dart';
import '/auth/screens/location_screen.dart';
import '/screens/search_field_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_product_card.dart';
import 'categories/categories_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final LocationData? locationData;
  const HomeScreen({
    super.key,
    this.locationData,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabBarController;
  final FirebaseServices _services = FirebaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  String area = '';
  String city = '';
  String state = '';
  String country = '';
  bool isLocationEmpty = false;

  @override
  void initState() {
    tabBarController = TabController(
      length: 3,
      vsync: this,
    );
    _services.getCurrentUserData().then((value) {
      if (value['location'] == null) {
        getEmptyLocationUI();
        return;
      }
      getAddressToUI();
    });
    super.initState();
  }

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
      tabBarController.animateTo(1);
    });
  }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Ionicons.location,
              size: 25,
              color: blueColor,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: blackColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Icon(
                        Ionicons.caret_down,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: fadedColor,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.to(
                () => const SearchFieldScreen(),
              ),
              child: const Icon(
                Ionicons.search,
                color: blackColor,
                size: 25,
              ),
            )
          ],
        ),
        bottom: TabBar(
          controller: tabBarController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: blueColor,
          indicatorWeight: 3,
          splashBorderRadius: BorderRadius.circular(10),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'SFProDisplay',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: 'SFProDisplay',
          ),
          labelColor: blackColor,
          unselectedLabelColor: lightBlackColor,
          tabs: const [
            Tab(
              text: 'Nearby',
            ),
            Tab(
              text: 'All Products',
            ),
            Tab(
              text: 'Categories',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabBarController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          //near me screen
          NearbyProductsScreen(
            city: city,
            isLocationEmpty: isLocationEmpty,
            tabBarController: tabBarController,
          ),
          //everywhere screen
          AllProductsScreen(
            city: city,
            tabBarController: tabBarController,
          ),
          const CategoriesListScreen(),
        ],
      ),
    );
  }
}

class AllProductsScreen extends StatefulWidget {
  final String city;
  final TabController tabBarController;

  const AllProductsScreen({
    super.key,
    required this.city,
    required this.tabBarController,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(
          //     left: 15,
          //     right: 15,
          //     top: 10,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       const Expanded(
          //         child: Text(
          //           'Browse Categories',
          //           maxLines: 2,
          //           overflow: TextOverflow.ellipsis,
          //           softWrap: true,
          //           style: TextStyle(
          //             fontWeight: FontWeight.w800,
          //             fontSize: 20,
          //           ),
          //         ),
          //       ),
          //       TextButton(
          //         onPressed: () => Get.toNamed(CategoriesListScreen.routeName),
          //         child: const Text(
          //           'See all',
          //           style: TextStyle(
          //             fontWeight: FontWeight.w600,
          //             fontSize: 14,
          //             color: blueColor,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.2,
          //   width: MediaQuery.of(context).size.width,
          //   child: FutureBuilder<QuerySnapshot>(
          //     future: widget._services.categories
          //         .orderBy('sortId', descending: false)
          //         .get(),
          //     builder: (BuildContext context,
          //         AsyncSnapshot<QuerySnapshot> snapshot) {
          //       if (snapshot.hasError) {
          //         return const Center(
          //           child: Padding(
          //             padding: EdgeInsets.all(15.0),
          //             child: Text(
          //               'Something has gone wrong. Please try again',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 15,
          //               ),
          //             ),
          //           ),
          //         );
          //       }
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Padding(
          //           padding: EdgeInsets.all(15.0),
          //           child: Center(
          //             child: SpinKitFadingCircle(
          //               color: lightBlackColor,
          //               size: 30,
          //               duration: Duration(milliseconds: 1000),
          //             ),
          //           ),
          //         );
          //       }
          //       return CarouselSlider.builder(
          //         itemCount: 6,
          //         options: CarouselOptions(
          //           viewportFraction: 0.9,
          //           pageSnapping: true,
          //           height: MediaQuery.of(context).size.height,
          //           enlargeCenterPage: false,
          //           enableInfiniteScroll: true,
          //           reverse: false,
          //           scrollDirection: Axis.horizontal,
          //           scrollPhysics: const BouncingScrollPhysics(),
          //         ),
          //         itemBuilder: (context, index, realIndex) {
          //           var doc = snapshot.data!.docs[index];
          //           return GestureDetector(
          //             behavior: HitTestBehavior.opaque,
          //             onTap: () => Get.to(
          //               () => SubCategoriesListScreen(doc: doc),
          //             ),
          //             child: Container(
          //               decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(10),
          //                 color: greyColor,
          //               ),
          //               margin: const EdgeInsets.symmetric(horizontal: 5),
          //               child: SizedBox(
          //                 width: MediaQuery.of(context).size.width,
          //                 child: Stack(
          //                   children: [
          //                     ClipRRect(
          //                       borderRadius: BorderRadius.circular(10),
          //                       child: CachedNetworkImage(
          //                         imageUrl: doc['image'],
          //                         fit: BoxFit.cover,
          //                         width: MediaQuery.of(context).size.width,
          //                         errorWidget: (context, url, error) {
          //                           return const Icon(
          //                             Ionicons.alert_circle,
          //                             size: 30,
          //                             color: redColor,
          //                           );
          //                         },
          //                         placeholder: (context, url) {
          //                           return const Center(
          //                             child: SpinKitFadingCircle(
          //                               color: lightBlackColor,
          //                               size: 30,
          //                               duration: Duration(milliseconds: 1000),
          //                             ),
          //                           );
          //                         },
          //                       ),
          //                     ),
          //                     Align(
          //                       alignment: Alignment.center,
          //                       child: Text(
          //                         doc['catName'],
          //                         maxLines: 1,
          //                         softWrap: true,
          //                         overflow: TextOverflow.ellipsis,
          //                         style: const TextStyle(
          //                           fontWeight: FontWeight.w900,
          //                           fontSize: 38,
          //                           color: whiteColor,
          //                           shadows: <Shadow>[
          //                             Shadow(
          //                               offset: Offset(0, 2),
          //                               blurRadius: 10.0,
          //                               color: lightBlackColor,
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: AutoSizeText(
              'Latest Products',
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          ProductsList(
            city: widget.city,
            isLocationEmpty: true,
            tabController: widget.tabBarController,
            showAll: true,
          ),
        ],
      ),
    );
  }
}

class NearbyProductsScreen extends StatefulWidget {
  final String city;
  final TabController tabBarController;
  final bool isLocationEmpty;

  const NearbyProductsScreen({
    super.key,
    required this.city,
    required this.tabBarController,
    required this.isLocationEmpty,
  });

  @override
  State<NearbyProductsScreen> createState() => _NearbyProductsScreenState();
}

class _NearbyProductsScreenState extends State<NearbyProductsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: AutoSizeText(
              'Nearby Products',
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          ProductsList(
            city: widget.city,
            isLocationEmpty: widget.isLocationEmpty,
            tabController: widget.tabBarController,
            showAll: false,
          ),
        ],
      ),
    );
  }
}

class ProductsList extends StatefulWidget {
  final String city;
  final bool isLocationEmpty;
  final bool showAll;
  final TabController tabController;
  const ProductsList({
    super.key,
    required this.city,
    required this.showAll,
    required this.isLocationEmpty,
    required this.tabController,
  });

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  final FirebaseServices _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return widget.isLocationEmpty && widget.showAll == false
        ? Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2Fempty.svg?alt=media&token=0d3a7bf1-cc6d-4448-bca9-7cf352dda71b',
                    semanticsLabel: 'Empty favorites image',
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) => const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: lightBlackColor,
                          size: 30,
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
                    'No products found in your region',
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
                  text: 'Show All Products',
                  onPressed: () {
                    widget.tabController.animateTo(1);
                  },
                  icon: Ionicons.earth,
                  borderColor: blueColor,
                  bgColor: blueColor,
                  textIconColor: whiteColor,
                ),
              ],
            ),
          )
        : FirestoreQueryBuilder(
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
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2Fempty.svg?alt=media&token=0d3a7bf1-cc6d-4448-bca9-7cf352dda71b',
                          semanticsLabel: 'Empty favorites image',
                          fit: BoxFit.contain,
                          placeholderBuilder: (BuildContext context) =>
                              const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Center(
                              child: SpinKitFadingCircle(
                                color: lightBlackColor,
                                size: 30,
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
                          'No products found in your region',
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
                        text: 'Show All Products',
                        onPressed: () {
                          widget.tabController.animateTo(1);
                        },
                        icon: Ionicons.earth,
                        borderColor: blueColor,
                        bgColor: blueColor,
                        textIconColor: whiteColor,
                      ),
                    ],
                  ),
                );
              }
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
                  bottom: 15,
                ),
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.docs[index];
                  var time =
                      DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
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
              );
            },
          );
  }
}
