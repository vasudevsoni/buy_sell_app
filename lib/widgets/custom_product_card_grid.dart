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

  const CustomProductCardGrid({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<CustomProductCardGrid> createState() => _CustomProductCardGridState();
}

class _CustomProductCardGridState extends State<CustomProductCardGrid> {
  final FirebaseServices services = FirebaseServices();
  bool isLiked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> getDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    if (widget.data['favorites'].contains(services.user!.uid)) {
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
            opacity: widget.data['isSold'] == true ? 0.5 : 1,
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
                            bottom: 7,
                            right: 7,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                isLiked = !isLiked;
                                services.updateFavorite(
                                  isLiked: isLiked,
                                  productId: widget.data.id,
                                );
                                isLiked
                                    ? showSnackBar(
                                        content: 'Added to favorites',
                                        color: blueColor,
                                      )
                                    : showSnackBar(
                                        content: 'Removed from favorites',
                                        color: redColor,
                                      );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  widget.data['favorites']
                                          .contains(services.user!.uid)
                                      ? Ionicons.heart
                                      : Ionicons.heart_outline,
                                  size: 21,
                                  color: redColor,
                                ),
                              ),
                            ),
                          ),
                        if (widget.data['views'].length >= 5 &&
                            widget.data['views'].length < 10)
                          Positioned(
                            top: 7,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 6),
                              decoration: BoxDecoration(
                                color: blueColor,
                                boxShadow: const [customShadow],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'Trending 📈',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ),
                        if (widget.data['views'].length >= 10 &&
                            widget.data['views'].length < 20)
                          Positioned(
                            top: 7,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 6),
                              decoration: BoxDecoration(
                                color: greenColor,
                                boxShadow: const [customShadow],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'Popular 🌟',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ),
                        if (widget.data['views'].length >= 20 &&
                            widget.data['views'].length < 50)
                          Positioned(
                            top: 7,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 6),
                              decoration: BoxDecoration(
                                color: redColor,
                                boxShadow: const [customShadow],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'Hot 🔥',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: whiteColor,
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
                        style: GoogleFonts.sora(
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
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                              priceFormat.format(widget.data['price']),
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                                fontSize: 14,
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
                              style: GoogleFonts.sora(
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
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        minFontSize: 11,
                        maxFontSize: 11,
                        style: GoogleFonts.sora(
                          color: blackColor,
                          fontWeight: FontWeight.w400,
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
