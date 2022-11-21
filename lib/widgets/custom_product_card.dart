import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ionicons/ionicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '/screens/product_details_screen.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';

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
              child: SpinKitFadingCircle(
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
                        width: size.width * 0.3,
                        height: size.width * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: widget.data['images'][0],
                            fit: BoxFit.cover,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: blackColor,
                                  fontSize: 14,
                                ),
                              ),
                              AutoSizeText(
                                priceFormat.format(widget.data['price']),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: blueColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              RichText(
                                text: TextSpan(
                                  text: '${timeago.format(widget.time)} •',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: lightBlackColor,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          ' ${widget.data['location']['area']}, ${widget.data['location']['city']}, ${widget.data['location']['state']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      isLiked = !isLiked;
                      services.updateFavorite(
                        isLiked: isLiked,
                        productId: widget.data.id,
                      );
                      setState(() {});
                    },
                    child: Icon(
                      isLiked ? Ionicons.heart : Ionicons.heart_outline,
                      size: 20,
                      color: isLiked ? pinkColor : lightBlackColor,
                    ),
                  ),
                ),
            ],
          );
  }
}
