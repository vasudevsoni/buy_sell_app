import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/product_details_screen.dart';
import '../services/firebase_services.dart';
import '../utils/utils.dart';

class CustomProductCard extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> data;
  final Future<DocumentSnapshot<Object?>> sellerDetails;
  final DateTime time;

  const CustomProductCard({
    Key? key,
    required this.data,
    required this.sellerDetails,
    required this.time,
  }) : super(key: key);

  @override
  State<CustomProductCard> createState() => _CustomProductCardState();
}

class _CustomProductCardState extends State<CustomProductCard> {
  FirebaseServices services = FirebaseServices();
  late DocumentSnapshot sellerDetails;
  List fav = [];
  bool isLiked = false;
  bool isLoading = false;

  NumberFormat priceFormat = NumberFormat.currency(
    locale: "en_IN",
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    await services.getUserData(widget.data['sellerUid']).then((value) {
      if (mounted) {
        setState(() {
          sellerDetails = value;
        });
      }
    });
    await services.listings.doc(widget.data.id).get().then((value) {
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCube(
                color: lightBlackColor,
                size: 30,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          )
        : Stack(
            children: [
              InkWell(
                splashFactory: InkRipple.splashFactory,
                splashColor: greyColor,
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ProductDetailsScreen(
                      productData: widget.data,
                      sellerData: sellerDetails,
                    );
                  },
                )),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: whiteColor,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.data['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 13,
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
                              RichText(
                                text: TextSpan(
                                  text: '${timeago.format(widget.time)} •',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.5,
                                    color: lightBlackColor,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          ' ${widget.data['location']['area']}, ${widget.data['location']['city']}, ${widget.data['location']['state']}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.5,
                                        color: lightBlackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
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
                  top: 0,
                  right: 0,
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
                    circleColor:
                        const CircleColor(start: redColor, end: blueColor),
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
