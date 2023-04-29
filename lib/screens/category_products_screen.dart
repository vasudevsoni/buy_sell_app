import 'package:buy_sell_app/widgets/custom_button_without_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../auth/screens/location_screen.dart';
import '../services/admob_services.dart';
import '../widgets/custom_loading_indicator.dart';
import '../widgets/svg_picture.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/screens/main_screen.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_product_card.dart';

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

class _CategoryProductsScreenState extends State<CategoryProductsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseServices _services = FirebaseServices();
  late TabController tabBarController;
  bool isLocationEmpty = false;
  String city = '';
  bool isLoading = true;
  late NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(
      length: 2,
      vsync: this,
    );
    _getCurrentUserData();
    _initNativeAd();
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
        city = value['location']['city'];
      });
    }
  }

  _getEmptyLocationUI() {
    if (mounted) {
      setState(() {
        isLocationEmpty = true;
      });
    }
  }

  _initNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: AdmobServices.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
          if (mounted) {
            ad.dispose();
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: smallNativeAdStyle,
    );
    // Preload the ad
    await _nativeAd!.load();
  }

  @override
  void dispose() {
    tabBarController.dispose();
    if (_nativeAd != null && mounted) {
      _nativeAd!.dispose();
    }
    super.dispose();
  }

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
          '${widget.catName} > ${widget.subCatName}',
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
        bottom: TabBar(
          controller: tabBarController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: blackColor,
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
          labelColor: blackColor,
          unselectedLabelColor: lightBlackColor,
          tabs: const [
            Tab(
              text: 'Nearby',
            ),
            Tab(
              text: 'Everywhere',
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
                NearbyProducts(
                  city: city,
                  catName: widget.catName,
                  subCatName: widget.subCatName,
                  isLocationEmpty: isLocationEmpty,
                  tabBarController: tabBarController,
                ),
                AllProducts(
                  city: city,
                  catName: widget.catName,
                  subCatName: widget.subCatName,
                  tabBarController: tabBarController,
                ),
              ],
            ),
      bottomNavigationBar: SmallNativeAd(
        nativeAd: _nativeAd,
        isAdLoaded: _isAdLoaded,
      ),
    );
  }
}

class NearbyProducts extends StatefulWidget {
  final String catName;
  final String subCatName;
  final String city;
  final TabController tabBarController;
  final bool isLocationEmpty;

  const NearbyProducts({
    super.key,
    required this.city,
    required this.catName,
    required this.subCatName,
    required this.tabBarController,
    required this.isLocationEmpty,
  });

  @override
  State<NearbyProducts> createState() => _NearbyProductsState();
}

class _NearbyProductsState extends State<NearbyProducts>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: CategoryScreenProductsList(
        city: widget.city,
        catName: widget.catName,
        subCatName: widget.subCatName,
        isLocationEmpty: widget.isLocationEmpty,
        tabController: widget.tabBarController,
        showAll: false,
      ),
    );
  }
}

class AllProducts extends StatefulWidget {
  final String catName;
  final String subCatName;
  final String city;
  final TabController tabBarController;

  const AllProducts({
    super.key,
    required this.catName,
    required this.subCatName,
    required this.city,
    required this.tabBarController,
  });

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: CategoryScreenProductsList(
        city: widget.city,
        catName: widget.catName,
        subCatName: widget.subCatName,
        isLocationEmpty: true,
        tabController: widget.tabBarController,
        showAll: true,
      ),
    );
  }
}

class CategoryScreenProductsList extends StatefulWidget {
  final String catName;
  final String subCatName;
  final String city;
  final bool isLocationEmpty;
  final bool showAll;
  final TabController tabController;
  const CategoryScreenProductsList({
    super.key,
    required this.catName,
    required this.subCatName,
    required this.city,
    required this.showAll,
    required this.isLocationEmpty,
    required this.tabController,
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
                    .where('catName', isEqualTo: widget.catName)
                    .where('subCat', isEqualTo: widget.subCatName)
                    .where('isActive', isEqualTo: true)
                    .orderBy(
                      'postedAt',
                      descending: true,
                    )
                : _services.listings
                    .where('catName', isEqualTo: widget.catName)
                    .where('subCat', isEqualTo: widget.subCatName)
                    .where('isActive', isEqualTo: true)
                    .where('location.city', isEqualTo: widget.city)
                    .orderBy(
                      'postedAt',
                      descending: true,
                    ),
            pageSize: 11,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'No products in this category',
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
                        text: 'Go to Home',
                        onPressed: () => Get.offAll(
                            () => const MainScreen(selectedIndex: 0)),
                        icon: MdiIcons.homeOutline,
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
                child: ListView.separated(
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
                            text: 'Show more',
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
              );
            },
          );
  }
}
