import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '/screens/product_details_screen.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import 'custom_loading_indicator.dart';

class CustomProductCard extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> data;

  const CustomProductCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<CustomProductCard> createState() => _CustomProductCardState();
}

class _CustomProductCardState extends State<CustomProductCard> {
  final FirebaseServices services = FirebaseServices();
  List fav = [];
  bool isLiked = false;
  bool isLoading = false;
  bool isSold = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> getDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      fav = widget.data['favorites'];
      isSold = widget.data['isSold'];
    });
    if (fav.contains(services.user!.uid)) {
      setState(() {
        isLiked = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLiked = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return isLoading
        ? const Center(
            child: CustomLoadingIndicator(),
          )
        : Opacity(
            opacity: isSold ? 0.5 : 1,
            child: Stack(
              children: [
                InkWell(
                  splashFactory: InkRipple.splashFactory,
                  splashColor: transparentColor,
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ProductDetailsScreen(
                          productData: widget.data,
                        );
                      },
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: whiteColor,
                      border: greyBorder,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            left: 3,
                            top: 3,
                            bottom: 3,
                          ),
                          width: size.width * 0.28,
                          height: size.width * 0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: widget.data['images'][0],
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              memCacheHeight: (size.height * 0.3).round(),
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Ionicons.alert_circle_outline,
                                  size: 30,
                                  color: redColor,
                                );
                              },
                              placeholder: (context, url) {
                                return const Icon(
                                  Ionicons.image,
                                  size: 30,
                                  color: lightBlackColor,
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: size.width * 0.3,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.data['catName'] == 'Jobs'
                                    ? Text(
                                        '${priceFormat.format(widget.data['salaryFrom'])} - ${priceFormat.format(widget.data['salaryTo'])}',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w800,
                                          color: blackColor,
                                          fontSize: 15,
                                        ),
                                      )
                                    : Text(
                                        priceFormat
                                            .format(widget.data['price']),
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w800,
                                          color: blackColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                if (widget.data['catName'] == 'Jobs')
                                  Column(
                                    children: [
                                      AutoSizeText(
                                        'Salary Period - ${widget.data['salaryPeriod']}',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w500,
                                          color: blackColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                    ],
                                  ),
                                Text(
                                  widget.data['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${widget.data['location']['area']}, ${widget.data['location']['city']}',
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.interTight(
                                    color: lightBlackColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
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
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        isLiked = !isLiked;
                        services.updateFavorite(
                          isLiked: isLiked,
                          productId: widget.data.id,
                        );
                      },
                      child: Icon(
                        isLiked ? Ionicons.heart : Ionicons.heart_outline,
                        size: 22,
                        color: isLiked ? redColor : blackColor,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}
