import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/full_bio_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_product_card.dart';
import '../services/firebase_services.dart';

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
  String name = '';
  String bio = '';
  String profileImage = '';
  String sellerUid = '';
  String address = '';
  DateTime dateJoined = DateTime.now();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await services.getUserData(widget.userId).then((value) {
      if (mounted) {
        setState(() {
          if (value['name'] == null) {
            name = 'BestDeal User';
          } else {
            name = value['name'];
          }
          if (value['bio'] == null) {
            bio = '';
          } else {
            bio = value['bio'];
          }
          if (value['profileImage'] == null) {
            profileImage = '';
          } else {
            profileImage = value['profileImage'];
          }
          if (value['location'] == null) {
            address == '';
          } else {
            address =
                '${value['location']['city']}, ${value['location']['state']}, ${value['location']['country']}';
          }
          sellerUid = value['uid'];
          dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          interactive: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                profileImage == ''
                    ? Container(
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: blueColor,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.userTie,
                          color: whiteColor,
                          size: 40,
                        ),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          showModal(
                            configuration:
                                const FadeScaleTransitionConfiguration(),
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
                                            const BouncingScrollPhysics(),
                                        itemCount: 1,
                                        builder:
                                            (BuildContext context, int index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: NetworkImage(
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
                                                FontAwesomeIcons
                                                    .circleExclamation,
                                                size: 20,
                                                color: redColor,
                                              );
                                            },
                                          );
                                        },
                                        loadingBuilder: (context, event) {
                                          return const Center(
                                            child: SpinKitFadingCube(
                                              color: greyColor,
                                              size: 20,
                                              duration:
                                                  Duration(milliseconds: 1000),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 15,
                                        left: 15,
                                        child: IconButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          splashColor: blueColor,
                                          splashRadius: 30,
                                          icon: const Icon(
                                            FontAwesomeIcons.circleXmark,
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
                          );
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 0.3,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: profileImage,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  FontAwesomeIcons.circleExclamation,
                                  size: 30,
                                  color: redColor,
                                );
                              },
                              placeholder: (context, url) {
                                return const Center(
                                  child: SpinKitFadingCube(
                                    color: lightBlackColor,
                                    size: 30,
                                    duration: Duration(milliseconds: 1000),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
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
                    style: GoogleFonts.poppins(
                      color: blackColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (bio != '')
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.to(
                        () => FullBioScreen(bio: bio),
                      );
                    },
                    child: Text(
                      bio,
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (address != '')
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          FontAwesomeIcons.mapLocationDot,
                          color: blueColor,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: AutoSizeText(
                            address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              color: lightBlackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                  child: Text(
                    'Joined ${timeago.format(dateJoined)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      color: blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Divider(
                  height: 30,
                  indent: 15,
                  endIndent: 15,
                  color: lightBlackColor,
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
                        'From this Seller',
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
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
      pageSize: 6,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCube(
                color: lightBlackColor,
                size: 20,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                'No listings from this seller',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 10,
              );
            },
            padding: const EdgeInsets.only(
              left: 15,
              top: 10,
              right: 15,
              bottom: 30,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.docs[index];
              var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
              var sellerDetails = _services.getUserData(data['sellerUid']);
              final hasMoreReached = snapshot.hasMore &&
                  index + 1 == snapshot.docs.length &&
                  !snapshot.isFetchingMore;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomProductCard(
                    data: data,
                    sellerDetails: sellerDetails,
                    time: time,
                  ),
                  if (hasMoreReached)
                    const SizedBox(
                      height: 10,
                    ),
                  if (hasMoreReached)
                    CustomButton(
                      text: 'Load more',
                      onPressed: () {
                        snapshot.fetchMore();
                      },
                      icon: FontAwesomeIcons.chevronDown,
                      borderColor: blackColor,
                      bgColor: blackColor,
                      textIconColor: whiteColor,
                    ),
                ],
              );
            },
            physics: const BouncingScrollPhysics(),
          );
        }
      },
    );
  }
}
