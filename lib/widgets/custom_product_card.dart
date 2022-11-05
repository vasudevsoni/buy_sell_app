import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/product_details_screen.dart';
import '../services/firebase_services.dart';
import '../utils/utils.dart';

class CustomProductCard extends StatefulWidget {
  const CustomProductCard({
    Key? key,
    required this.data,
    required this.sellerDetails,
    required this.time,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final Future<DocumentSnapshot<Object?>> sellerDetails;
  final DateTime time;

  @override
  State<CustomProductCard> createState() => _CustomProductCardState();
}

class _CustomProductCardState extends State<CustomProductCard> {
  FirebaseServices services = FirebaseServices();
  late DocumentSnapshot sellerDetails;
  List fav = [];
  bool isLiked = false;
  NumberFormat priceFormat = NumberFormat.currency(
    locale: "en_IN",
    symbol: '₹',
    decimalDigits: 0,
  );

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
        if (fav.contains(services.user!.uid)) {
          setState(() {
            isLiked = true;
          });
        } else {
          setState(() {
            isLiked = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                spreadRadius: 2,
                blurRadius: 7,
                color: greyColor,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ProductDetailsScreen(
                      productData: widget.data, sellerData: sellerDetails);
                },
              ));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: widget.data['images'][0],
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return const Icon(
                          FontAwesomeIcons.circleExclamation,
                          size: 30,
                          color: redColor,
                        );
                      },
                      placeholder: (context, url) {
                        return const Icon(
                          FontAwesomeIcons.solidImage,
                          size: 30,
                          color: lightBlackColor,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: blackColor,
                            fontSize: 12,
                          ),
                        ),
                        AutoSizeText(
                          priceFormat.format(widget.data['price']),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: blueColor,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${widget.data['location']['area']}, ${widget.data['location']['city']}, ${widget.data['location']['state']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: lightBlackColor,
                          ),
                        ),
                        Text(
                          timeago.format(widget.time),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: fadedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.data['sellerUid'] != services.user!.uid)
          Positioned(
            top: 3,
            right: 3,
            child: LikeButton(
              isLiked: isLiked,
              likeCountPadding: const EdgeInsets.all(0),
              likeBuilder: (isLiked) {
                return Icon(
                  isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  size: 20,
                  color: isLiked ? pinkColor : lightBlackColor,
                );
              },
              bubblesColor: const BubblesColor(
                dotPrimaryColor: redColor,
                dotSecondaryColor: pinkColor,
                dotThirdColor: redColor,
                dotLastColor: pinkColor,
              ),
              bubblesSize: 60,
              circleColor: const CircleColor(start: redColor, end: blueColor),
              animationDuration: const Duration(milliseconds: 1300),
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
    );
  }
}
