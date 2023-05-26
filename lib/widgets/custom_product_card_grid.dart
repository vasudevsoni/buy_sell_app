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

class CustomProductCardGrid extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> data;
  final DateTime time;

  const CustomProductCardGrid({
    Key? key,
    required this.data,
    required this.time,
  }) : super(key: key);

  @override
  State<CustomProductCardGrid> createState() => _CustomProductCardGridState();
}

class _CustomProductCardGridState extends State<CustomProductCardGrid> {
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
            child: InkWell(
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
                  //
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.data['images'][0],
                            fit: BoxFit.cover,
                            height: size.width * 0.45,
                            width: size.width,
                            filterQuality: FilterQuality.high,
                            memCacheHeight: (size.height * 0.5).round(),
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
                        if (widget.data['sellerUid'] != services.user!.uid)
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                isLiked = !isLiked;
                                services.updateFavorite(
                                  isLiked: isLiked,
                                  productId: widget.data.id,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isLiked
                                      ? Ionicons.heart
                                      : Ionicons.heart_outline,
                                  size: 22,
                                  color: isLiked ? redColor : blackColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Text(
                        widget.data['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: widget.data['catName'] == 'Jobs'
                          ? AutoSizeText(
                              '${priceFormat.format(widget.data['salaryFrom'])} - ${priceFormat.format(widget.data['salaryTo'])}',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                                fontSize: 15,
                              ),
                            )
                          : Text(
                              priceFormat.format(widget.data['price']),
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                                fontSize: 15,
                              ),
                            ),
                    ),
                    if (widget.data['catName'] == 'Jobs')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              'Salary Period - ${widget.data['salaryPeriod']}',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w500,
                                color: blackColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: AutoSizeText(
                        '${widget.data['location']['area']}, ${widget.data['location']['city']}',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        minFontSize: 8,
                        maxFontSize: 11,
                        style: GoogleFonts.interTight(
                          color: lightBlackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
