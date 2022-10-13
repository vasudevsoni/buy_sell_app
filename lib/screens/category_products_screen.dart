import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/product_provider.dart';
import '../services/firebase_services.dart';
import '../utils/utils.dart';
import 'product_details_screen.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          widget.subCatName,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                'Results',
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
            ),
          ],
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
          .where('subCat', isEqualTo: widget.subCatName)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Some error occurred. Please try again');
        } else if (snapshot.hasData && snapshot.data!.size == 0) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.heartCrack,
                    size: 60,
                    color: redColor,
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
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(MainScreen.routeName);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to Home',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: blueColor,
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        const Icon(
                          FontAwesomeIcons.house,
                          size: 13,
                          color: blueColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCube(
                color: blueColor,
                size: 30,
                duration: Duration(milliseconds: 1000),
              ),
            ),
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
          physics: const BouncingScrollPhysics(),
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
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.data['images'][0],
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return const Icon(
                            FontAwesomeIcons.triangleExclamation,
                            size: 20,
                            color: redColor,
                          );
                        },
                        placeholder: (context, url) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: blueColor,
                              size: 30,
                              duration: Duration(milliseconds: 1000),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
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
                            timeago.format(widget.time),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: lightBlackColor,
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
        ),
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
