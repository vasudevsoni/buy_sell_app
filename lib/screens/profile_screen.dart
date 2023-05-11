import 'package:buy_sell_app/screens/user_rating_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/admob_services.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_loading_indicator.dart';
import '../widgets/custom_product_card_grid.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/external_link_icon_widget.dart';
import '../widgets/text_field_label.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import 'full_bio_screen.dart';
import '/services/firebase_services.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseServices services = FirebaseServices();
  final TextEditingController reportTextController = TextEditingController();
  String name = '';
  String bio = '';
  String profileImage = '';
  String sellerUid = '';
  String address = '';
  String instagramLink = '';
  String facebookLink = '';
  String websiteLink = '';
  double rating = 0;

  DateTime dateJoined = DateTime.now();
  // int followers = 0;
  // int following = 0;

  // bool isFollowing = false;

  final NumberFormat numberFormat = NumberFormat.compact();

  late NativeAd? _nativeAd;
  // late BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    _initNativeAd();
    // _initBannerAd();
  }

  Future<void> getUserData() async {
    final value = await services.getUserData(widget.userId);
    if (!mounted) return;

    setState(() {
      name = value['name'] ?? 'BechDe User';
      bio = value['bio'] ?? '';
      profileImage = value['profileImage'] ?? '';
      address = value['location'] != null
          ? '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}'
          : '';
      instagramLink = value['instagramLink'] ?? '';
      facebookLink = value['facebookLink'] ?? '';
      websiteLink = value['websiteLink'] ?? '';
      sellerUid = value['uid'];
      dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
      rating = value['rating'] == 0
          ? 0
          : (value['rating'] / (value['ratedBy'].length - 1));
      // isFollowing = value['followers'].contains(user!.uid);
      // followers = value['followers'].isEmpty ? 0 : value['followers'].length;
      // following = value['following'].isEmpty ? 0 : value['following'].length;
    });
  }

  _initNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: AdmobServices.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
          if (mounted) {
            ad.dispose();
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: smallNativeAdStyle,
    );
    // Preload the ad
    await _nativeAd!.load();
  }

  // _initBannerAd() {
  //   _bannerAd = BannerAd(
  //     size: AdSize.banner,
  //     adUnitId: AdmobServices.bannerAdUnitId,
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         setState(() {
  //           _isAdLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         setState(() {
  //           _isAdLoaded = false;
  //         });
  //         if (mounted) {
  //           ad.dispose();
  //         }
  //       },
  //     ),
  //     request: const AdRequest(),
  //   );
  //   // Preload the ad
  //   _bannerAd!.load();
  // }

  showReportDialog() {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: transparentColor,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: whiteColor,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 15,
              left: 15,
              right: 15,
              top: 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: fadedColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    'Report this user',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const TextFieldLabel(labelText: 'Message'),
                CustomTextField(
                  controller: reportTextController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  showCounterText: true,
                  maxLength: 1000,
                  maxLines: 3,
                  hint: 'Explain in detail why you are reporting this user',
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        bgColor: whiteColor,
                        borderColor: greyColor,
                        textIconColor: blackColor,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: CustomButton(
                        icon: MdiIcons.arrowRight,
                        text: 'Report',
                        onPressed: () {
                          if (reportTextController.text.isEmpty) {
                            return;
                          }
                          services.reportUser(
                            message: reportTextController.text,
                            userId: sellerUid,
                          );
                          Get.back();
                          reportTextController.clear();
                        },
                        bgColor: redColor,
                        borderColor: redColor,
                        textIconColor: whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: transparentColor,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: whiteColor,
            ),
            padding: const EdgeInsets.only(
              left: 15,
              top: 5,
              right: 15,
              bottom: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: fadedColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  icon: MdiIcons.shieldAccountOutline,
                  text: 'Report User',
                  onPressed: () {
                    Get.back();
                    showReportDialog();
                  },
                  isFullWidth: true,
                  bgColor: whiteColor,
                  borderColor: redColor,
                  textIconColor: redColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    reportTextController.dispose();
    if (_nativeAd != null && mounted) {
      _nativeAd!.dispose();
    }
    // if (_bannerAd != null && mounted) {
    //   _bannerAd!.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: showOptionsDialog,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              MdiIcons.dotsVertical,
              color: blackColor,
              size: 25,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
        title: Text(
          name,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      bottomNavigationBar: SmallNativeAd(
        nativeAd: _nativeAd,
        isAdLoaded: _isAdLoaded,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  profileImage == ''
                      ? Container(
                          height: size.width * 0.25,
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: blueColor,
                          ),
                          child: const Icon(
                            MdiIcons.accountOutline,
                            color: whiteColor,
                            size: 40,
                          ),
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) {
                              return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.down,
                                onDismissed: (direction) {
                                  Get.back();
                                },
                                child: Material(
                                  color: blackColor,
                                  child: Stack(
                                    children: [
                                      PhotoViewGallery.builder(
                                        scrollPhysics:
                                            const ClampingScrollPhysics(),
                                        itemCount: 1,
                                        builder:
                                            (BuildContext context, int index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider:
                                                CachedNetworkImageProvider(
                                              profileImage,
                                            ),
                                            initialScale: PhotoViewComputedScale
                                                    .contained *
                                                1,
                                            minScale: PhotoViewComputedScale
                                                    .contained *
                                                1,
                                            maxScale: PhotoViewComputedScale
                                                    .contained *
                                                2,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                MdiIcons.alertDecagramOutline,
                                                size: 20,
                                                color: redColor,
                                              );
                                            },
                                          );
                                        },
                                        loadingBuilder: (context, event) {
                                          return const Center(
                                            child: CustomLoadingIndicator(),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 15,
                                        right: 15,
                                        child: IconButton(
                                          onPressed: () => Get.back(),
                                          splashColor: transparentColor,
                                          splashRadius: 30,
                                          icon: const Icon(
                                            MdiIcons.closeCircleOutline,
                                            size: 30,
                                            color: whiteColor,
                                            shadows: [
                                              BoxShadow(
                                                offset: Offset(0, 0),
                                                blurRadius: 15,
                                                spreadRadius: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          child: Container(
                            height: size.width * 0.25,
                            width: size.width * 0.25,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            margin: const EdgeInsets.only(left: 15, right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                imageUrl: profileImage,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                memCacheHeight: (size.width * 0.25).round(),
                                memCacheWidth: (size.width * 0.25).round(),
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    MdiIcons.alertDecagramOutline,
                                    size: 30,
                                    color: redColor,
                                  );
                                },
                                placeholder: (context, url) {
                                  return const Center(
                                    child: CustomLoadingIndicator(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: rating > 0 && rating < 3
                          ? redColor
                          : rating == 3
                              ? Colors.orange
                              : rating == 0
                                  ? blackColor
                                  : greenColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          rating == 0 ? 'Unrated' : rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 15,
                            color: whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        const Icon(
                          MdiIcons.star,
                          size: 15,
                          color: whiteColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  name,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    color: blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (instagramLink == '' &&
                  facebookLink == '' &&
                  websiteLink == '')
                const SizedBox(
                  height: 5,
                ),
              if (instagramLink != '' ||
                  facebookLink != '' ||
                  websiteLink != '')
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (instagramLink != '')
                            ExternalLinkIcon(
                              icon: Ionicons.logo_instagram,
                              iconColor: const Color(0xffdd2a7b),
                              link: instagramLink,
                            ),
                          if (facebookLink != '')
                            ExternalLinkIcon(
                              icon: Ionicons.logo_facebook,
                              iconColor: const Color(0xff1778f2),
                              link: facebookLink,
                            ),
                          if (websiteLink != '')
                            ExternalLinkIcon(
                              icon: MdiIcons.linkVariant,
                              iconColor: blueColor,
                              link: websiteLink,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              if (bio != '')
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.to(
                          () => FullBioScreen(bio: bio),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              MdiIcons.informationOutline,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              bio,
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                color: blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Icon(
                      MdiIcons.calendarAccount,
                      size: 15,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Joined - ${timeago.format(dateJoined)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: GoogleFonts.interTight(
                        color: blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (address != '')
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          const Icon(
                            MdiIcons.mapMarker,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.interTight(
                              color: blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  CustomButton(
                    text: 'Rate User',
                    onPressed: () async {
                      final value = await services.getUserData(sellerUid);
                      if (value['ratedBy'].contains(services.user!.uid)) {
                        showSnackBar(
                          content: 'You have already rated this user',
                          color: redColor,
                        );
                      } else {
                        Get.to(
                          () => UserRatingScreen(
                            userId: sellerUid,
                            name: name,
                          ),
                        );
                      }
                    },
                    icon: MdiIcons.starOutline,
                    borderColor: blueColor,
                    bgColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                ],
              ),
              // SizedBox(
              //   height: 10,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 15),
              //   child: isFollowing
              //       ? CustomButton(
              //           text: 'Unfollow',
              //           onPressed: () {
              //             services.followUser(
              //               currentUserId: user!.uid,
              //               userId: sellerUid,
              //               isFollowed: false,
              //             );
              //             setState(() {
              //               isFollowing = false;
              //             });
              //           },
              //           icon: Ionicons.person_remove,
              //           borderColor: blackColor,
              //           bgColor: blackColor,
              //           textIconColor: whiteColor,
              //         )
              //       : CustomButton(
              //           text: 'Follow',
              //           onPressed: () {
              //             services.followUser(
              //               currentUserId: user!.uid,
              //               userId: sellerUid,
              //               isFollowed: true,
              //             );
              //             setState(() {
              //               isFollowing = true;
              //             });
              //           },
              //           icon: Ionicons.person_add,
              //           borderColor: blueColor,
              //           bgColor: blueColor,
              //           textIconColor: whiteColor,
              //         ),
              // ),
              const Divider(
                height: 20,
                thickness: 3,
                color: greyColor,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: Text(
                      'Currently Selling',
                      maxLines: 1,
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SellerProductsList(
                    sellerUid: sellerUid,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellerProductsList extends StatefulWidget {
  final String sellerUid;
  const SellerProductsList({
    super.key,
    required this.sellerUid,
  });

  @override
  State<SellerProductsList> createState() => _SellerProductsListState();
}

class _SellerProductsListState extends State<SellerProductsList> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: _services.listings
          .orderBy(
            'postedAt',
            descending: true,
          )
          .where('sellerUid', isEqualTo: widget.sellerUid)
          .where('isActive', isEqualTo: true),
      pageSize: 12,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: CustomLoadingIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                'No products from this seller',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return AlignedGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: const EdgeInsets.only(
            left: 15,
            top: 10,
            right: 15,
            bottom: 15,
          ),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.docs[index];
            final time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
            final hasMoreReached = snapshot.hasMore &&
                index + 1 == snapshot.docs.length &&
                !snapshot.isFetchingMore;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomProductCardGrid(
                  data: data,
                  time: time,
                ),
                if (hasMoreReached)
                  const SizedBox(
                    height: 10,
                  ),
                if (hasMoreReached)
                  CustomButtonWithoutIcon(
                    text: 'Show more',
                    onPressed: () => snapshot.fetchMore(),
                    borderColor: blackColor,
                    bgColor: whiteColor,
                    textIconColor: blackColor,
                  ),
              ],
            );
          },
          physics: const ClampingScrollPhysics(),
        );
      },
    );
  }
}
