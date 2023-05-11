import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../auth/screens/location_screen.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_loading_indicator.dart';
import '../widgets/custom_product_card_grid.dart';
import '../widgets/svg_picture.dart';
import '/widgets/custom_button.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import 'categories/categories_list_screen.dart';
import 'categories/sub_categories_list_screen.dart';
import 'search_field_screen.dart';

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
  final _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;
  String area = '';
  String city = '';
  String state = '';
  bool isLocationEmpty = false;
  bool isLoading = true;

  late DateTime currentBackPressTime;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(
      length: 3,
      vsync: this,
    );
    _getCurrentUserData();
  }

  void _getCurrentUserData() async {
    final value = await _services.getCurrentUserData();
    if (value['location'] == null) {
      _getEmptyLocationUI();
    } else {
      _getAddressToUI(value);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _getAddressToUI(DocumentSnapshot<Object?> value) {
    if (mounted) {
      setState(() {
        area = value['location']['area'];
        city = value['location']['city'];
        state = value['location']['state'];
      });
    }
  }

  _getEmptyLocationUI() {
    if (mounted) {
      setState(() {
        isLocationEmpty = true;
        tabBarController.index = 1;
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
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(10),
  //               topRight: Radius.circular(10),
  //             ),
  //             color: whiteColor,
  //           ),
  //           padding: EdgeInsets.only(
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
  //               SizedBox(
  //                 height: 10,
  //               ),
  //               Center(
  //                 child: Text(
  //                   'Filter your Results',
  //                   style: GoogleFonts.interTight(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                   textAlign: TextAlign.start,
  //                 ),
  //               ),
  //               SizedBox(
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
  //               SizedBox(
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
      //   child: Icon(Mdicons.filterVariant),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: blueColor,
        iconTheme: const IconThemeData(color: whiteColor),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              MdiIcons.mapMarkerOutline,
              size: 20,
              color: whiteColor,
            ),
            const SizedBox(
              width: 3,
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.to(
                  () => const LocationScreen(
                    isOpenedFromSellButton: false,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      isLocationEmpty == true ? 'Set Location' : city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: whiteColor,
                      ),
                    ),
                    const Icon(
                      MdiIcons.chevronDown,
                      size: 18,
                      color: whiteColor,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(
                () => const SearchFieldScreen(),
              ),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: whiteColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    const Icon(
                      MdiIcons.magnify,
                      color: whiteColor,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      'Search',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: tabBarController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: whiteColor,
          indicatorWeight: 3,
          splashFactory: InkRipple.splashFactory,
          splashBorderRadius: BorderRadius.circular(10),
          labelStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: whiteColor,
          unselectedLabelColor: whiteColor,
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
      body: isLoading == true
          ? const CustomLoadingIndicator()
          : TabBarView(
              controller: tabBarController,
              physics: const BouncingScrollPhysics(),
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
                Expanded(
                  child: Text(
                    'Categories',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.tabBarController.animateTo(2),
                  child: Text(
                    'See all',
                    style: GoogleFonts.interTight(
                      color: blueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CategoriesListView(size: size, services: _services),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Latest Products',
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
      height: size.height * 0.1,
      child: StreamBuilder<QuerySnapshot>(
        stream: _services.categories
            .orderBy('sortId', descending: false)
            .limit(5)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 6,
              );
            },
            itemCount: snapshot.data!.docs.length,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return InkWell(
                onTap: () => Get.to(
                  () => SubCategoriesListScreen(doc: doc),
                ),
                borderRadius: BorderRadius.circular(10),
                splashFactory: InkRipple.splashFactory,
                splashColor: transparentColor,
                child: Ink(
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: greyBorder,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  width: size.height * 0.14,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: doc['image'],
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.high,
                          errorWidget: (context, url, error) {
                            return const Icon(
                              MdiIcons.alertDecagramOutline,
                              size: 30,
                              color: redColor,
                            );
                          },
                          placeholder: (context, url) {
                            return const Center(
                              child: CustomLoadingIndicator(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        doc['catName'],
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
                Expanded(
                  child: Text(
                    'Categories',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.tabBarController.animateTo(2),
                  child: Text(
                    'See all',
                    style: GoogleFonts.interTight(
                      color: blueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CategoriesListView(size: size, services: _services),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Nearby Products',
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w700,
                fontSize: 18,
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

// class CustomBannerAdHomeScreen extends StatefulWidget {
//   CustomBannerAdHomeScreen({super.key});

//   @override
//   State<CustomBannerAdHomeScreen> createState() =>
//       _CustomBannerAdHomeScreenState();
// }

// class _CustomBannerAdHomeScreenState extends State<CustomBannerAdHomeScreen> {
//   late BannerAd? _bannerAd;
//   bool _isAdLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _initBannerAd();
//   }

//   _initBannerAd() {
//     _bannerAd = BannerAd(
//       size: AdSize.largeBanner,
//       adUnitId: AdmobServices.bannerAdUnitId,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isAdLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           setState(() {
//             _isAdLoaded = false;
//           });
//           ad.dispose();
//         },
//       ),
//       request: AdRequest(),
//     );
//     _bannerAd!.load();
//   }

//   @override
//   void dispose() {
//     _bannerAd!.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return _isAdLoaded
//         ? Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: greyColor,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             height: size.width * 0.3,
//             width: 300,
//             child: AdWidget(ad: _bannerAd!),
//           )
//         : Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: greyColor,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             height: size.width * 0.3,
//             width: 300,
//             child: Center(
//               child: Text('Ad'),
//             ),
//           );
//   }
// }

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
                        'https://res.cloudinary.com/bechdeapp/image/upload/v1674460581/illustrations/empty_qjocex.svg',
                    fit: BoxFit.contain,
                    semanticsLabel: 'Empty products image',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Set your location to see nearby products',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomButton(
                  text: 'Set Location',
                  onPressed: () {
                    Get.to(
                      () => const LocationScreen(
                        isOpenedFromSellButton: false,
                      ),
                    );
                  },
                  icon: MdiIcons.crosshairsGps,
                  borderColor: blackColor,
                  bgColor: blackColor,
                  textIconColor: whiteColor,
                ),
                CustomButton(
                  text: 'Show All Products',
                  onPressed: () {
                    widget.tabController.animateTo(1);
                  },
                  icon: MdiIcons.earth,
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
            pageSize: 12,
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
                              'https://res.cloudinary.com/bechdeapp/image/upload/v1674460581/illustrations/empty_qjocex.svg',
                          fit: BoxFit.contain,
                          semanticsLabel: 'Empty products image',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'No products are currently available',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return AlignedGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
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
                  final hasMoreReached = snapshot.hasMore &&
                      index + 1 == snapshot.docs.length &&
                      !snapshot.isFetchingMore;
                  // if (index != 0 && index % 5 == 0) {
                  //   return CustomBannerAdHomeScreen();
                  // }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomProductCardGrid(
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
              );
            },
          );
  }
}
