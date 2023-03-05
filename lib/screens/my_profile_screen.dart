import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:ionicons/ionicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../widgets/custom_loading_indicator.dart';
import '../widgets/external_link_icon_widget.dart';
import '/auth/screens/email_verification_screen.dart';
import '/auth/screens/location_screen.dart';
import 'full_bio_screen.dart';
import 'help_and_support_screen.dart';
import 'my_listings_screen.dart';
import '/screens/selling/seller_categories_list_screen.dart';
import 'settings_screen.dart';
import 'update_profile_image_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/services/firebase_services.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final FirebaseServices services = FirebaseServices();
  final InAppReview inAppReview = InAppReview.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  String name = '';
  String profileImage = '';
  String bio = '';
  String address = '';
  // int followers = 0;
  // int following = 0;
  String instagramLink = '';
  String facebookLink = '';
  String websiteLink = '';
  var iconSize = 16;

  DateTime dateJoined = DateTime.now();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await services.getCurrentUserData().then((value) {
      if (mounted) {
        setState(() {
          if (value['name'] == 'BechDe User') {
            name = 'BechDe User';
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
                '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}';
          }
          if (value['instagramLink'] == null) {
            instagramLink = '';
          } else {
            instagramLink = value['instagramLink'];
          }
          if (value['facebookLink'] == null) {
            facebookLink = '';
          } else {
            facebookLink = value['facebookLink'];
          }
          if (value['websiteLink'] == null) {
            websiteLink = '';
          } else {
            websiteLink = value['websiteLink'];
          }
          // if (value['followers'].isEmpty) {
          //   followers = 0;
          // } else {
          //   followers = value['followers'].length;
          // }
          // if (value['following'].isEmpty) {
          //   following = 0;
          // } else {
          //   following = value['following'].length;
          // }
          dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
        });
      }
    });
  }

  onSellButtonClicked() async {
    await services.getCurrentUserData().then((value) {
      if (value['location'] == null) {
        Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
        showSnackBar(
          content: 'Please set your location to sell products',
          color: redColor,
        );
      } else {
        Get.to(
          () => const SellerCategoriesListScreen(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              profileImage == ''
                  ? Stack(
                      children: [
                        Container(
                          height: size.width * 0.25,
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: blueColor,
                          ),
                          child: const Icon(
                            Ionicons.person,
                            color: whiteColor,
                            size: 50,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Get.to(
                                () => const UpdateProfileImageScreen(),
                              );
                            },
                            child: const Icon(
                              Ionicons.create_outline,
                              color: lightBlackColor,
                              shadows: [
                                Shadow(
                                  color: lightBlackColor,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) {
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
                                    builder: (BuildContext context, int index) {
                                      return PhotoViewGalleryPageOptions(
                                        imageProvider:
                                            CachedNetworkImageProvider(
                                          profileImage,
                                        ),
                                        initialScale:
                                            PhotoViewComputedScale.contained *
                                                1,
                                        minScale:
                                            PhotoViewComputedScale.contained *
                                                1,
                                        maxScale:
                                            PhotoViewComputedScale.contained *
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
                                        child: CustomLoadingIndicator(),
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
                      child: Stack(
                        children: [
                          Container(
                            height: size.width * 0.25,
                            width: size.width * 0.25,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: const EdgeInsets.all(3),
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
                                    Ionicons.alert_circle,
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Get.to(
                                  () => const UpdateProfileImageScreen(),
                                );
                              },
                              child: const Icon(
                                Ionicons.create_outline,
                                color: blackColor,
                                shadows: [
                                  Shadow(
                                    color: lightBlackColor,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
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
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    color: blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: bio == ''
                    ? () {}
                    : () => Get.to(
                          () => FullBioScreen(bio: bio),
                        ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    bio == '' ? 'Your bio will show here' : bio,
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      color: blackColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            icon: Ionicons.link,
                            iconColor: blueColor,
                            link: websiteLink,
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Joined - ${timeago.format(dateJoined)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.interTight(
                    color: lightBlackColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
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
                    style: GoogleFonts.interTight(
                      color: lightBlackColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make money selling on BechDe 💸',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.interTight(
                        color: blackColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Ionicons.checkmark_circle,
                                color: greenColor,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  'List unlimited products for free',
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.interTight(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Ionicons.checkmark_circle,
                                color: greenColor,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  'Reach thousands of buyers',
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.interTight(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Ionicons.checkmark_circle,
                                color: greenColor,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  'Your listings won\'t expire',
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.interTight(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                      text: 'List a Product',
                      isFullWidth: true,
                      onPressed: !user!.emailVerified &&
                              user!.providerData[0].providerId == 'password'
                          ? () => Get.to(
                                () => const EmailVerificationScreen(),
                              )
                          : onSellButtonClicked,
                      icon: Icons.add_rounded,
                      bgColor: blueColor,
                      borderColor: blueColor,
                      textIconColor: whiteColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    MyProfileItemWidget(
                      icon: Ionicons.albums_outline,
                      iconColor: blackColor,
                      text: 'My Listings',
                      onTap: () => Get.to(
                        () => const MyListingsScreen(),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MyProfileItemWidget(
                      icon: Ionicons.cog_outline,
                      iconColor: blackColor,
                      text: 'Settings',
                      onTap: () => Get.to(
                        () => const SettingsScreen(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    MyProfileItemWidget(
                      icon: Ionicons.help_circle_outline,
                      iconColor: redColor,
                      text: 'Help & Support',
                      onTap: () => Get.to(
                        () => const HelpAndSupportScreen(),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MyProfileItemWidget(
                      icon: Ionicons.star_outline,
                      iconColor: blueColor,
                      text: 'Leave a Review',
                      onTap: () {
                        inAppReview.openStoreListing();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: whiteColor,
                    border: Border.all(
                      color: greyColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Made with ',
                          style: GoogleFonts.interTight(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: lightBlackColor,
                          ),
                        ),
                        Icon(
                          Ionicons.heart,
                          color: redColor,
                          size: iconSize.toDouble(),
                        ),
                        Text(
                          ' in India',
                          style: GoogleFonts.interTight(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: lightBlackColor,
                          ),
                        ),
                      ],
                    ),
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

class MyProfileItemWidget extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const MyProfileItemWidget({
    Key? key,
    required this.iconColor,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashFactory: InkRipple.splashFactory,
        splashColor: fadedColor,
        child: Ink(
          height: 90,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: whiteColor,
            border: Border.all(
              color: greyColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                size: 30,
                color: iconColor,
              ),
              AutoSizeText(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
