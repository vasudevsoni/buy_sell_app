import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
// import 'package:geocode/geocode.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../provider/product_provider.dart';
import 'categories/sub_categories_list_screen.dart';
import '../../widgets/custom_text_field.dart';
import '../services/firebase_services.dart';
import 'categories/categories_list_screen.dart';
import 'product_details_screen.dart';

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
  TextEditingController searchController = TextEditingController();
  String defaultAddress = 'India';
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
  void initState() {
    // getAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseServices service = FirebaseServices();

    var list = [
      'vehicles',
      'real estate',
      'electronics',
      'furniture',
      'stationary',
      'kitchen appliances',
      'antiques',
    ];
    final random = Random();
    String element = list[random.nextInt(list.length)];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(defaultAddress),
                        const Icon(
                          FontAwesomeIcons.solidSquareCaretDown,
                        )
                      ],
                    ),
                    const Icon(
                      FontAwesomeIcons.solidHeart,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: CustomTextField(
                        controller: searchController,
                        keyboardType: TextInputType.text,
                        label: 'Search for anything',
                        hint: 'Search for $element',
                        maxLength: 100,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: AutoSizeText(
                        'What are you looking for?',
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(CategoriesListScreen.routeName);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'See all',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: blueColor,
                              ),
                            ),
                            const Icon(
                              FontAwesomeIcons.circleArrowRight,
                              size: 13,
                              color: blueColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.11,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: FutureBuilder<QuerySnapshot>(
                  future: service.categories
                      .orderBy('sortId', descending: false)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Some error occurred. Please try again.'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Text('Loading...'),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubCategoriesListScreen(doc: doc),
                              ),
                            );
                          },
                          child: CategoryContainer(
                            text: doc['catName'],
                            url: doc['image'],
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
                child: Text(
                  'Latest Products',
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const HomeScreenProductsList(),
              const Text('The End')
            ],
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
    var provider = Provider.of<ProductProvider>(context);

    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );

    return FutureBuilder<QuerySnapshot>(
      future: _services.listings
          .orderBy(
            'postedAt',
            descending: true,
          )
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Some error occurred. Please try again');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
            var sellerDetails = _services.getSellerData(data['sellerUid']);

            return ProductCard(
              provider: provider,
              data: data,
              sellerDetails: sellerDetails,
              priceFormat: priceFormat,
              time: time,
            );
          },
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    required this.provider,
    required this.data,
    required this.sellerDetails,
    required this.priceFormat,
    required this.time,
  }) : super(key: key);

  final ProductProvider provider;
  final QueryDocumentSnapshot<Object?> data;
  final Future<DocumentSnapshot<Object?>> sellerDetails;
  final NumberFormat priceFormat;
  final DateTime time;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  FirebaseServices services = FirebaseServices();
  late DocumentSnapshot sellerDetails;

  @override
  void initState() {
    services.getSellerData(widget.data['sellerUid']).then((value) {
      setState(() {
        sellerDetails = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () {
                widget.provider.getProductDetails(widget.data);
                widget.provider.getSellerDetails(sellerDetails);
                Navigator.of(context).pushNamed(ProductDetailsScreen.routeName);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 1,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.data['images'][0],
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.67,
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            widget.priceFormat.format(widget.data['price']),
                            maxLines: 1,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: blueColor,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.data['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: lightBlackColor,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            timeago.format(widget.time),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: LikeButton(
                circleColor: const CircleColor(
                  start: Color.fromARGB(255, 255, 0, 0),
                  end: Color.fromARGB(255, 237, 34, 34),
                ),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                animationDuration: const Duration(milliseconds: 1000),
                likeBuilder: (bool isLiked) {
                  return isLiked
                      ? const Icon(
                          FontAwesomeIcons.solidHeart,
                          color: Colors.red,
                          size: 18,
                        )
                      : const Icon(
                          FontAwesomeIcons.heart,
                          color: Colors.red,
                          size: 18,
                        );
                },
              ),
            ),
          ],
        ),
        const Divider(
          height: 0,
          color: fadedColor,
          indent: 15,
          endIndent: 15,
        )
      ],
    );
  }
}

class CategoryContainer extends StatelessWidget {
  final String text;
  final String url;
  const CategoryContainer({
    Key? key,
    required this.text,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.11,
      width: MediaQuery.of(context).size.height * 0.11,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: greyColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.height * 0.05,
            image: NetworkImage(
              url,
            ),
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 3,
          ),
          AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 10,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: fadedColor,
            ),
          ),
        ],
      ),
    );
  }
}
