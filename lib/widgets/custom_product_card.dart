import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '/screens/product_details_screen.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import 'custom_loading_indicator.dart';

class CustomProductCard extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> data;
  final DateTime time;

  const CustomProductCard({
    Key? key,
    required this.data,
    required this.time,
  }) : super(key: key);

  @override
  State<CustomProductCard> createState() => _CustomProductCardState();
}

class _CustomProductCardState extends State<CustomProductCard> {
  final FirebaseServices services = FirebaseServices();
  List fav = [];
  bool isLiked = false;
  bool isLoading = false;

  @override
  void initState() {
    getFavDetails();
    super.initState();
  }

  Future<void> getFavDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      fav = widget.data['favorites'];
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
        ? const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: CustomLoadingIndicator(),
            ),
          )
        : Stack(
            children: [
              InkWell(
                splashFactory: InkRipple.splashFactory,
                splashColor: fadedColor,
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
                    border: Border.all(
                      color: greyColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: SizedBox(
                          width: size.width * 0.3,
                          height: size.width * 0.3,
                          child: CachedNetworkImage(
                            imageUrl: widget.data['images'][0],
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            memCacheHeight: (size.height * 0.3).round(),
                            errorWidget: (context, url, error) {
                              return const Icon(
                                MdiIcons.alertDecagram,
                                size: 30,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Icon(
                                MdiIcons.imageFilterHdr,
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
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text(
                                      priceFormat.format(widget.data['price']),
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w800,
                                        color: blackColor,
                                        fontSize: 16,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${widget.data['location']['area']}, ${widget.data['location']['city']}',
                                      maxLines: widget.data['catName'] == 'Jobs'
                                          ? 1
                                          : 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.interTight(
                                        color: lightBlackColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      timeago.format(widget.time),
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.interTight(
                                        color: lightBlackColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
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
                      isLiked ? MdiIcons.heart : MdiIcons.heartOutline,
                      size: 22,
                      color: isLiked ? redColor : lightBlackColor,
                    ),
                  ),
                ),
            ],
          );
  }
}
