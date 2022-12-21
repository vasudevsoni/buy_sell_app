import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:location/location.dart';

import '../auth/screens/location_screen.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/svg_picture.dart';
import '/widgets/custom_button.dart';
import '/services/firebase_services.dart';
import '/screens/search_field_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_product_card.dart';
import 'categories/categories_list_screen.dart';
import 'categories/sub_categories_list_screen.dart';

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
  final User? user = FirebaseAuth.instance.currentUser;
  String area = '';
  String city = '';
  String state = '';
  bool isLocationEmpty = false;

  late DateTime currentBackPressTime;

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
        });
      }
    });
  }

  getEmptyLocationUI() async {
    if (mounted) {
      setState(() {
        isLocationEmpty = true;
        tabBarController.animateTo(1);
      });
    }
  }

  // showFilterBottomSheet() {
  //   showModalBottomSheet<dynamic>(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: transparentColor,
  //     builder: (context) {
  //       return SafeArea(
  //         child: Container(
  //           decoration: const BoxDecoration(
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(10),
  //               topRight: Radius.circular(10),
  //             ),
  //             color: whiteColor,
  //           ),
  //           padding: const EdgeInsets.only(
  //             top: 5,
  //             left: 15,
  //             right: 15,
  //             bottom: 15,
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Center(
  //                 child: Container(
  //                   width: 80.0,
  //                   height: 5.0,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10.0),
  //                     color: fadedColor,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               const Center(
  //                 child: Text(
  //                   'Filter your Results',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                   textAlign: TextAlign.start,
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               CustomButtonWithoutIcon(
  //                 text: 'Show Products in My Area',
  //                 onPressed: () async {
  //                   Get.back();
  //                 },
  //                 bgColor: blueColor,
  //                 borderColor: blueColor,
  //                 textIconColor: whiteColor,
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               CustomButtonWithoutIcon(
  //                 text: 'Show Products in My City',
  //                 onPressed: () => Get.back(),
  //                 bgColor: blueColor,
  //                 borderColor: blueColor,
  //                 textIconColor: whiteColor,
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      // floatingActionButton: FloatingActionButton.small(
      //   onPressed: showFilterBottomSheet,
      //   backgroundColor: blueColor,
      //   elevation: 0,
      //   focusElevation: 0,
      //   hoverElevation: 0,
      //   disabledElevation: 0,
      //   highlightElevation: 0,
      //   child: const Icon(Ionicons.filter),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        elevation: 0.2,
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
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.to(
                  () => const LocationScreen(
                    isOpenedFromSellButton: false,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
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
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: blackColor,
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
                        '$city, $state',
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
        physics: const ClampingScrollPhysics(),
        children: [
          //near me screen
          NearbyProductsScreen(
            city: city,
            isLocationEmpty: isLocationEmpty,
            tabBarController: tabBarController,
          ),
          //all products screen
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
  final FirebaseServices _services = FirebaseServices();
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    super.build(context);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Browse Categories',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                ActionChip(
                  label: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'See all',
                        style: TextStyle(
                          color: blueColor,
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Icon(
                        Ionicons.arrow_forward,
                        color: blueColor,
                        size: 12,
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(
                    color: blueColor,
                  ),
                  backgroundColor: whiteColor,
                  onPressed: () => widget.tabBarController.animateTo(2),
                ),
              ],
            ),
          ),
          CategoriesListView(size: size, services: _services),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
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

class CategoriesListView extends StatelessWidget {
  final Size size;
  final FirebaseServices _services;

  const CategoriesListView({
    Key? key,
    required this.size,
    required FirebaseServices services,
  })  : _services = services,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height * 0.10,
      child: FutureBuilder<QuerySnapshot>(
        future: _services.categories.orderBy('sortId', descending: false).get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 10,
              );
            },
            itemCount: 6,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.to(
                  () => SubCategoriesListScreen(doc: doc),
                ),
                child: Container(
                  width: size.height * 0.15,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: greyColor,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: CachedNetworkImage(
                            imageUrl: doc['image'],
                            fit: BoxFit.fitHeight,
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Ionicons.alert_circle,
                                size: 30,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Center(
                                child: SpinKitFadingCircle(
                                  color: lightBlackColor,
                                  size: 30,
                                  duration: Duration(milliseconds: 1000),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Text(
                        doc['catName'],
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: lightBlackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
  final FirebaseServices _services = FirebaseServices();
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    super.build(context);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Browse Categories',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                ActionChip(
                  label: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'See all',
                        style: TextStyle(
                          color: blueColor,
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Icon(
                        Ionicons.arrow_forward,
                        color: blueColor,
                        size: 12,
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(
                    color: blueColor,
                  ),
                  backgroundColor: whiteColor,
                  onPressed: () => widget.tabBarController.animateTo(2),
                ),
              ],
            ),
          ),
          CategoriesListView(size: size, services: _services),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
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
    final size = MediaQuery.of(context).size;
    return widget.isLocationEmpty && widget.showAll == false
        ? Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    semanticsLabel: 'Empty products image',
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
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          semanticsLabel: 'Empty products image',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'No products are currently available',
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
                );
              }
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 10,
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
              );
            },
          );
  }
}
