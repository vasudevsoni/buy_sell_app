import 'package:buy_sell_app/screens/follow_us_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:ionicons/ionicons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
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
  String name = 'BechDe User';
  String profileImage = '';
  String bio = '';
  String address = '';
  String instagramLink = '';
  String facebookLink = '';
  String websiteLink = '';
  var iconSize = 16;
  DateTime dateJoined = DateTime.now();
  // int followers = 0;
  // int following = 0;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final value = await services.getCurrentUserData();
    if (mounted) {
      setState(() {
        name = value['name'] ?? name;
        bio = value['bio'] ?? '';
        profileImage = value['profileImage'] ?? '';
        address = value['location'] != null
            ? '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}'
            : '';
        instagramLink = value['instagramLink'] ?? '';
        facebookLink = value['facebookLink'] ?? '';
        websiteLink = value['websiteLink'] ?? '';
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
  }

  onSellButtonClicked() async {
    final value = await services.getCurrentUserData();
    final location = value['location'];
    if (location == null) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: AutoSizeText(
                  'Profile',
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              profileImage == ''
                  ? Center(
                      child: Stack(
                        children: [
                          Container(
                            height: size.width * 0.25,
                            width: size.width * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: blueColor,
                            ),
                            child: const Icon(
                              MdiIcons.account,
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
                                MdiIcons.pencilBoxOutline,
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
                      ),
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
                                            MdiIcons.alertDecagram,
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
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              height: size.width * 0.25,
                              width: size.width * 0.25,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
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
                                      MdiIcons.alertDecagram,
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
                                  MdiIcons.pencilBoxOutline,
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
                    ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Center(
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
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: bio.isEmpty
                    ? null
                    : () => Get.to(() => FullBioScreen(bio: bio)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Text(
                      bio == '' ? 'Your bio will show here' : bio,
                      maxLines: 2,
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
                            icon: MdiIcons.linkVariant,
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
                child: Center(
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
              ),
              if (address != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
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
                ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [blueColor, greenColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Make money selling on BechDe',
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.interTight(
                            color: whiteColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          MdiIcons.cashMultiple,
                          color: whiteColor,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                MdiIcons.checkCircle,
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
                                MdiIcons.checkCircle,
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
                                MdiIcons.checkCircle,
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
                      icon: MdiIcons.basketPlusOutline,
                      bgColor: whiteColor,
                      borderColor: whiteColor,
                      textIconColor: blackColor,
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
                      icon: MdiIcons.shopping,
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
                      icon: MdiIcons.cog,
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
                      icon: MdiIcons.helpCircle,
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
                      icon: MdiIcons.star,
                      iconColor: blueColor,
                      text: 'Rate our App',
                      onTap: () {
                        inAppReview.openStoreListing();
                      },
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
                      icon: MdiIcons.shareVariant,
                      iconColor: blackColor,
                      text: 'Invite Friends',
                      onTap: () => Share.share(
                          'Hey! I found some really amazing deals on the BechDe app.\nAnd you can also sell products without any listing fees or monthly limits.\nDownload it now - https://play.google.com/store/apps/details?id=com.bechde.buy_sell_app'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MyProfileItemWidget(
                      icon: MdiIcons.accountMultiplePlus,
                      iconColor: blackColor,
                      text: 'Follow Us',
                      onTap: () => Get.to(
                        () => const FollowUsScreen(),
                      ),
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
                            fontWeight: FontWeight.w500,
                            color: blackColor,
                          ),
                        ),
                        Icon(
                          MdiIcons.heart,
                          color: redColor,
                          size: iconSize.toDouble(),
                        ),
                        Text(
                          ' in India',
                          style: GoogleFonts.interTight(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
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
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
