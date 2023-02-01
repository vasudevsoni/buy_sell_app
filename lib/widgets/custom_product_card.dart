import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
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
    getDetails();
    super.initState();
  }

  getDetails() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await services.listings.doc(widget.data.id).get().then((value) {
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
        return;
      }
      if (mounted) {
        setState(() {
          isLiked = false;
        });
      }
    });
    if (mounted) {
      setState(() {
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ProductDetailsScreen(
                      productData: widget.data,
                    );
                  },
                )),
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
                                Ionicons.alert_circle,
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
                              Text(
                                priceFormat.format(widget.data['price']),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                widget.data['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: blackColor,
                                  fontSize: 14.5,
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
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: lightBlackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      timeago.format(widget.time),
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        color: lightBlackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
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
                      isLiked ? Ionicons.heart : Ionicons.heart_outline,
                      size: 22,
                      color: isLiked ? redColor : lightBlackColor,
                    ),
                  ),
                ),
            ],
          );
  }
}
