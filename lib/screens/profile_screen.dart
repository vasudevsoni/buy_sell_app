import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/text_field_label.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import 'full_bio_screen.dart';
import '/widgets/custom_product_card.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;
  String name = '';
  String bio = '';
  String profileImage = '';
  String sellerUid = '';
  String address = '';
  DateTime dateJoined = DateTime.now();
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  NumberFormat numberFormat = NumberFormat.compact();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await services.getUserData(widget.userId).then((value) {
      if (!mounted) {
        return;
      }
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
        if (value['followers'].contains(user!.uid)) {
          isFollowing = true;
        } else {
          isFollowing = false;
        }
        if (value['followers'].isEmpty) {
          followers = 0;
        } else {
          followers = value['followers'].length;
        }
        if (value['following'].isEmpty) {
          following = 0;
        } else {
          following = value['following'].length;
        }
        sellerUid = value['uid'];
        dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
      });
    });
  }

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
                const Center(
                  child: Text(
                    'Report this user',
                    style: TextStyle(
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
                CustomButton(
                  icon: Ionicons.arrow_forward,
                  text: 'Submit',
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
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
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
                  icon: Ionicons.shield_half,
                  text: 'Report User',
                  onPressed: () {
                    Get.back();
                    showReportDialog();
                  },
                  bgColor: whiteColor,
                  borderColor: redColor,
                  textIconColor: redColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: showOptionsDialog,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Ionicons.ellipsis_horizontal,
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
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    profileImage == ''
                        ? Container(
                            height: size.width * 0.3,
                            width: size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: blueColor,
                            ),
                            child: const Icon(
                              Ionicons.person,
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
                                              const BouncingScrollPhysics(),
                                          itemCount: 1,
                                          builder: (BuildContext context,
                                              int index) {
                                            return PhotoViewGalleryPageOptions(
                                              imageProvider: NetworkImage(
                                                profileImage,
                                              ),
                                              initialScale:
                                                  PhotoViewComputedScale
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
                                                  Ionicons.alert_circle,
                                                  size: 20,
                                                  color: redColor,
                                                );
                                              },
                                            );
                                          },
                                          loadingBuilder: (context, event) {
                                            return const Center(
                                              child: SpinKitFadingCircle(
                                                color: greyColor,
                                                size: 30,
                                                duration: Duration(
                                                    milliseconds: 1000),
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 15,
                                          right: 15,
                                          child: IconButton(
                                            onPressed: () => Get.back(),
                                            splashColor: blueColor,
                                            splashRadius: 30,
                                            icon: const Icon(
                                              Ionicons.close_circle_outline,
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
                            child: SizedBox(
                              height: size.width * 0.3,
                              width: size.width * 0.3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: profileImage,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return const Icon(
                                      Ionicons.alert_circle,
                                      size: 30,
                                      color: redColor,
                                    );
                                  },
                                  placeholder: (context, url) {
                                    return const Center(
                                      child: SpinKitFadingCircle(
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Builder(builder: (context) {
                                return Text(
                                  numberFormat.format(followers),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: const TextStyle(
                                    color: blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              }),
                              const Text(
                                'Followers',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                numberFormat.format(following),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: const TextStyle(
                                  color: blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Text(
                                'Following',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  style: const TextStyle(
                    color: blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (bio != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.to(
                      () => FullBioScreen(bio: bio),
                    ),
                    child: Text(
                      bio,
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Member since - ${DateFormat.yMMM().format(dateJoined)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    color: lightBlackColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              if (address != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      color: lightBlackColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: isFollowing
                    ? CustomButton(
                        text: 'Unfollow',
                        onPressed: () {
                          services.followUser(
                            currentUserId: user!.uid,
                            userId: sellerUid,
                            isFollowed: false,
                          );
                          setState(() {
                            isFollowing = false;
                          });
                        },
                        icon: Ionicons.person_remove,
                        borderColor: blackColor,
                        bgColor: blackColor,
                        textIconColor: whiteColor,
                      )
                    : CustomButton(
                        text: 'Follow',
                        onPressed: () {
                          services.followUser(
                            currentUserId: user!.uid,
                            userId: sellerUid,
                            isFollowed: true,
                          );
                          setState(() {
                            isFollowing = true;
                          });
                        },
                        icon: Ionicons.person_add,
                        borderColor: blueColor,
                        bgColor: blueColor,
                        textIconColor: whiteColor,
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: Text(
                      'Currently Selling',
                      maxLines: 1,
                      style: TextStyle(
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
      pageSize: 6,
      builder: (context, snapshot, child) {
        if (snapshot.isFetching) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCircle(
                color: lightBlackColor,
                size: 30,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                'No products from this seller',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 13,
            );
          },
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
                  CustomButtonWithoutIcon(
                    text: 'Load More',
                    onPressed: () => snapshot.fetchMore(),
                    borderColor: blackColor,
                    bgColor: whiteColor,
                    textIconColor: blackColor,
                  ),
              ],
            );
          },
          physics: const BouncingScrollPhysics(),
        );
      },
    );
  }
}
