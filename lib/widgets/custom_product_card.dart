import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/product_details_screen.dart';
import '../services/firebase_services.dart';
import '../utils/utils.dart';

class CustomProductCard extends StatefulWidget {
  const CustomProductCard({
    Key? key,
    required this.data,
    required this.sellerDetails,
    required this.priceFormat,
    required this.time,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final Future<DocumentSnapshot<Object?>> sellerDetails;
  final NumberFormat priceFormat;
  final DateTime time;

  @override
  State<CustomProductCard> createState() => _CustomProductCardState();
}

class _CustomProductCardState extends State<CustomProductCard> {
  FirebaseServices services = FirebaseServices();
  late DocumentSnapshot sellerDetails;
  List fav = [];
  bool isLiked = false;

  @override
  void initState() {
    getFavorites();
    getSellerDetails();
    super.initState();
  }

  getSellerDetails() {
    services.getUserData(widget.data['sellerUid']).then((value) {
      if (mounted) {
        setState(() {
          sellerDetails = value;
        });
      }
    });
  }

  getFavorites() {
    services.listings.doc(widget.data.id).get().then((value) {
      if (mounted) {
        setState(() {
          fav = value['favorites'];
        });
      }
      if (fav.contains(services.user!.uid)) {
        if (mounted) {
          setState(() {
            isLiked = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLiked = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.of(context).push(
            PageTransition(
              child: ProductDetailsScreen(
                productData: widget.data,
                sellerData: sellerDetails,
              ),
              type: PageTransitionType.rightToLeftWithFade,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                right: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.data['images'][0],
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) {
                    return const Icon(
                      Iconsax.warning_24,
                      size: 30,
                      color: redColor,
                    );
                  },
                  placeholder: (context, url) {
                    return const Icon(
                      Iconsax.image4,
                      size: 30,
                      color: lightBlackColor,
                    );
                  },
                ),
              ),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 10,
                    right: 10,
                    bottom: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.data['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      AutoSizeText(
                        widget.priceFormat.format(widget.data['price']),
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
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
                if (widget.data['sellerUid'] != services.user!.uid)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: LikeButton(
                      isLiked: isLiked,
                      likeBuilder: (isLiked) {
                        return Icon(
                          isLiked ? Iconsax.heart5 : Iconsax.heart4,
                          size: 22,
                          color: redColor,
                        );
                      },
                      bubblesColor: const BubblesColor(
                        dotPrimaryColor: blueColor,
                        dotSecondaryColor: redColor,
                        dotThirdColor: blueColor,
                        dotLastColor: redColor,
                      ),
                      animationDuration: const Duration(milliseconds: 1000),
                      onTap: (isLiked) async {
                        this.isLiked = !isLiked;
                        services.updateFavorite(
                          context: context,
                          isLiked: !isLiked,
                          productId: widget.data.id,
                        );
                        setState(() {});
                        return !isLiked;
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
