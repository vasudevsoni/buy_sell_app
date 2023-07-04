import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../auth/screens/location_screen.dart';
import '../provider/providers.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_loading_indicator.dart';
import '../widgets/custom_product_card_grid.dart';
import '../widgets/svg_picture.dart';
import '/widgets/custom_button.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import 'categories/sub_categories_list_screen.dart';
import 'search_field_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabBarController;

  final FirebaseServices _services = FirebaseServices();
  String area = '';
  String city = '';
  String state = '';
  bool isLocationEmpty = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 1,
    );
    _getCurrentUserData();
  }

  Future<void> _getCurrentUserData() async {
    final value = await _services.getCurrentUserData();

    if (value['location'] == null) {
      showEmptyLocationUI();
    } else {
      showMainUI(value);
    }
    if ((value.data() as dynamic)['adsRemoved'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AppNavigationProvider>(context, listen: false).removeAds();
      });
    }
  }

  void showMainUI(DocumentSnapshot<Object?> value) {
    if (mounted) {
      setState(() {
        area = value['location']['area'];
        city = value['location']['city'];
        state = value['location']['state'];
        isLoading = false;
      });
    }
  }

  void showEmptyLocationUI() {
    if (mounted) {
      setState(() {
        isLocationEmpty = true;
        tabBarController.index = 1;
        isLoading = false;
      });
    }
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
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Ionicons.location_outline,
              size: 20,
              color: blackColor,
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
                        color: blackColor,
                      ),
                    ),
                    const Icon(
                      Ionicons.chevron_down,
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
              child: const Icon(
                Ionicons.search,
                color: blackColor,
                size: 20,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: tabBarController,
          indicatorColor: blueColor,
          indicatorWeight: 3,
          splashFactory: InkRipple.splashFactory,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          labelColor: blueColor,
          unselectedLabelColor: lightBlackColor,
          tabs: const [
            Tab(
              text: 'Nearby',
            ),
            Tab(
              text: 'All Products',
            ),
          ],
        ),
      ),
      body: isLoading
          ? const CustomLoadingIndicator()
          : TabBarView(
              controller: tabBarController,
              physics: const BouncingScrollPhysics(),
              children: [
                //nearby screen
                NearbyProductsScreen(
                  city: city,
                  isLocationEmpty: isLocationEmpty,
                  tabBarController: tabBarController,
                  services: _services,
                ),
                //all screen
                AllProductsScreen(
                  city: city,
                  tabBarController: tabBarController,
                  services: _services,
                ),
              ],
            ),
    );
  }
}

class AllProductsScreen extends StatefulWidget {
  final String city;
  final TabController tabBarController;
  final FirebaseServices services;

  const AllProductsScreen({
    super.key,
    required this.city,
    required this.tabBarController,
    required this.services,
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
    final size = MediaQuery.of(context).size;
    final mainProv = Provider.of<AppNavigationProvider>(context);
    super.build(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                  onTap: () => mainProv.switchToPage(2),
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
          CategoriesListView(size: size, services: widget.services),
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

class NearbyProductsScreen extends StatefulWidget {
  final String city;
  final TabController tabBarController;
  final bool isLocationEmpty;
  final FirebaseServices services;

  const NearbyProductsScreen({
    super.key,
    required this.city,
    required this.tabBarController,
    required this.isLocationEmpty,
    required this.services,
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
    final size = MediaQuery.of(context).size;
    final mainProv = Provider.of<AppNavigationProvider>(context);
    super.build(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                  onTap: () => mainProv.switchToPage(2),
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
          CategoriesListView(size: size, services: widget.services),
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
            physics: const BouncingScrollPhysics(),
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
                              Ionicons.alert_circle_outline,
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
                  onPressed: () => Get.to(
                    () => const LocationScreen(
                      isOpenedFromSellButton: false,
                    ),
                  ),
                  icon: Ionicons.locate,
                  borderColor: blackColor,
                  bgColor: blackColor,
                  textIconColor: whiteColor,
                ),
                CustomButton(
                  text: 'Show All Products',
                  onPressed: () => widget.tabController.animateTo(1),
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
            pageSize: 16,
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
                  final hasMoreReached = snapshot.hasMore &&
                      index + 1 == snapshot.docs.length &&
                      !snapshot.isFetchingMore;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomProductCardGrid(
                        data: data,
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
