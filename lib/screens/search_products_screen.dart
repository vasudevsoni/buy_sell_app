import 'package:auto_size_text/auto_size_text.dart';
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

class SearchProductsScreen extends StatefulWidget {
  final String searchQuery;
  const SearchProductsScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Search results',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchScreenProductsList(
            query: widget.searchQuery,
          ),
        ],
      ),
    );
  }
}

class SearchScreenProductsList extends StatefulWidget {
  final String query;
  const SearchScreenProductsList({
    super.key,
    required this.query,
  });

  @override
  State<SearchScreenProductsList> createState() =>
      _SearchScreenProductsListState();
}

class _SearchScreenProductsListState extends State<SearchScreenProductsList> {
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
          .startAt([widget.query]).endAt(['${widget.query}\uf8ff']).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Some error occurred. Please try again');
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 1,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
