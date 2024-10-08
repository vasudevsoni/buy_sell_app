import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/follow_us_screen.dart';
import 'package:buy_sell_app/screens/how_to_use_screen.dart';
import 'package:buy_sell_app/screens/my_favorites_screen.dart';
import 'package:buy_sell_app/screens/remove_ads_screen.dart';
import 'package:buy_sell_app/widgets/custom_list_tile_with_subtitle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../widgets/custom_loading_indicator.dart';
import '../widgets/external_link_icon_widget.dart';
import 'full_bio_screen.dart';
import 'help_and_support_screen.dart';
import 'my_listings_screen.dart';
import 'settings_screen.dart';
import 'update_profile_image_screen.dart';
import '/utils/utils.dart';
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
  String instagramLink = '';
  String facebookLink = '';
  String websiteLink = '';
  var iconSize = 16;
  DateTime dateJoined = DateTime.now();
  double rating = 0;
  bool adsRemoved = false;
  // int followers = 0;
  // int following = 0;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    final value = await services.getCurrentUserData();
    if (mounted) {
      setState(() {
        name = value['name'] ?? name;
        bio = value['bio'] ?? '';
        profileImage = value['profileImage'] ?? '';
        instagramLink = value['instagramLink'] ?? '';
        facebookLink = value['facebookLink'] ?? '';
        websiteLink = value['websiteLink'] ?? '';
        dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
        adsRemoved = (value.data() as dynamic)['adsRemoved'] ?? false;
        rating = value['rating'] == 0
            ? 0
            : (value['rating'] / (value['ratedBy'].length - 1));
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
      });
    }
  }

  // onSellButtonClicked() async {
  //   final value = await services.getCurrentUserData();
  //   final location = value['location'];
  //   if (location == null) {
  //     Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
  //     showSnackBar(
  //       content: 'Please set your location to sell products',
  //       color: redColor,
  //     );
  //   } else {
  //     Get.to(
  //       () => const SellerCategoriesListScreen(),
  //     );
  //   }
  // }

  void showInAppReviewDialog() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing();
    }
  }

  void _showRatingDialog() {
    final dialog = RatingDialog(
      initialRating: 5.0,
      submitButtonTextStyle: GoogleFonts.interTight(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: blueColor,
      ),
      title: Text(
        'Rate our app',
        textAlign: TextAlign.center,
        style: GoogleFonts.interTight(
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
      message: Text(
        'Tap a star to set your rating. Add some comments if you want',
        textAlign: TextAlign.center,
        style: GoogleFonts.interTight(fontSize: 15),
      ),
      submitButtonText: 'Submit',
      commentHint: 'Enter comments here',
      onCancelled: () {},
      onSubmitted: (response) {
        if (response.rating < 3.0) {
          services.submitFeedback(text: response.comment);
        } else {
          showInAppReviewDialog();
        }
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => dialog,
    );
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
        title: Text(
          'My Account',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: GoogleFonts.interTight(
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
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                                Ionicons.person_outline,
                                color: whiteColor,
                                size: 50,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Get.to(
                                  () => const UpdateProfileImageScreen(),
                                ),
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
                          onTap: () => openProfileImage(context),
                          child: Stack(
                            children: [
                              Container(
                                height: size.width * 0.25,
                                width: size.width * 0.25,
                                margin: const EdgeInsets.only(left: 15),
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
                                        Ionicons.alert_circle_outline,
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
                                  onTap: () => Get.to(
                                    () => const UpdateProfileImageScreen(),
                                  ),
                                  child: const Icon(
                                    Ionicons.create_outline,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () => showSnackBar(
                      content: 'This is your star rating given by other users',
                      color: blueColor,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                            rating == 0.0
                                ? 'Unrated'
                                : rating.toStringAsFixed(1),
                            style: GoogleFonts.interTight(
                              fontSize: 15,
                              color: whiteColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          const Icon(
                            Ionicons.star,
                            size: 15,
                            color: whiteColor,
                          ),
                        ],
                      ),
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
                              icon: Ionicons.link,
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
                              Ionicons.information_circle_outline,
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
                      Ionicons.calendar_number_outline,
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
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () => Get.to(
                  () => const HowToUseScreen(),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: greyBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: size.height * 0.12,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg?auto=compress&cs=tinysrgb&w=600',
                          fit: BoxFit.cover,
                          width: size.width,
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: size.width * 0.9,
                          child: AutoSizeText(
                            'How to use BechDe?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.interTight(
                              color: whiteColor,
                              fontSize: 28,
                              shadows: [customShadow],
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: greyBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // To activate listings
                    // CustomButton(
                    //   text: 'check',
                    //   isFullWidth: true,
                    //   onPressed: () => services.activateListings(),
                    //   icon: Ionicons.checkbox,
                    //   bgColor: blueColor,
                    //   borderColor: blueColor,
                    //   textIconColor: whiteColor,
                    // ),
                    CustomListTileWithSubtitle(
                      text: 'My Listings',
                      subTitle: 'Manage your listings',
                      icon: Ionicons.bag_outline,
                      trailingIcon: Ionicons.chevron_forward,
                      isEnabled: true,
                      onTap: () => Get.to(
                        () => const MyListingsScreen(),
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: fadedColor,
                      indent: 15,
                    ),
                    CustomListTileWithSubtitle(
                      text: 'My Favorites',
                      subTitle: 'Manage your favorites',
                      icon: Ionicons.heart_outline,
                      trailingIcon: Ionicons.chevron_forward,
                      isEnabled: true,
                      onTap: () => Get.to(
                        () => const MyFavoritesScreen(),
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: fadedColor,
                      indent: 15,
                    ),
                    CustomListTileWithSubtitle(
                      text: 'Settings',
                      subTitle: 'Edit profile, location and log out',
                      icon: Ionicons.cog_outline,
                      trailingIcon: Ionicons.chevron_forward,
                      isEnabled: true,
                      onTap: () => Get.to(
                        () => const SettingsScreen(),
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: fadedColor,
                      indent: 15,
                    ),
                    CustomListTileWithSubtitle(
                      text: 'Help & Support',
                      subTitle: 'Contact us, read guidelines and more',
                      icon: Ionicons.help_outline,
                      trailingIcon: Ionicons.chevron_forward,
                      isEnabled: true,
                      onTap: () => Get.to(
                        () => const HelpAndSupportScreen(),
                      ),
                    ),
                    if (adsRemoved == false)
                      Column(
                        children: [
                          const Divider(
                            height: 0,
                            color: fadedColor,
                            indent: 15,
                          ),
                          CustomListTileWithSubtitle(
                            text: 'Remove Ads',
                            subTitle: 'Remove all ads from the app',
                            icon: Ionicons.diamond_outline,
                            trailingIcon: Ionicons.chevron_forward,
                            isEnabled: true,
                            onTap: () => Get.to(
                              () => const RemoveAdsScreen(),
                            ),
                          ),
                        ],
                      ),
                    const Divider(
                      height: 0,
                      color: fadedColor,
                      indent: 15,
                    ),
                    CustomListTileWithSubtitle(
                      text: 'Follow us',
                      subTitle: 'Follow us on social media',
                      icon: Ionicons.people_circle_outline,
                      trailingIcon: Ionicons.chevron_forward,
                      isEnabled: true,
                      onTap: () => Get.to(
                        () => const FollowUsScreen(),
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: fadedColor,
                      indent: 15,
                    ),
                    CustomListTileWithSubtitle(
                      text: 'Rate our app',
                      subTitle: 'Rate our app on the Play Store',
                      icon: Ionicons.star_outline,
                      isEnabled: true,
                      onTap: () => _showRatingDialog(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 15),
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              //   decoration: BoxDecoration(
              //     color: whiteColor,
              //     border: greyBorder,
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const SizedBox(
              //         height: 5,
              //       ),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Sell on BechDe & make extra cash',
              //             maxLines: 2,
              //             softWrap: true,
              //             overflow: TextOverflow.ellipsis,
              //             style: GoogleFonts.interTight(
              //               color: blackColor,
              //               fontWeight: FontWeight.w600,
              //               fontSize: 15,
              //             ),
              //           ),
              //           const Divider(
              //             color: lightBlackColor,
              //             height: 15,
              //             thickness: 1,
              //           ),
              //           Row(
              //             children: [
              //               const Icon(
              //                 Ionicons.checkmark_circle,
              //                 color: greenColor,
              //                 size: 15,
              //               ),
              //               const SizedBox(
              //                 width: 5,
              //               ),
              //               Expanded(
              //                 child: Text(
              //                   'List unlimited products for free',
              //                   maxLines: 2,
              //                   softWrap: true,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: GoogleFonts.interTight(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.w500,
              //                     color: blackColor,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //           Row(
              //             children: [
              //               const Icon(
              //                 Ionicons.checkmark_circle,
              //                 color: greenColor,
              //                 size: 15,
              //               ),
              //               const SizedBox(
              //                 width: 5,
              //               ),
              //               Expanded(
              //                 child: Text(
              //                   'Reach tens of thousands of buyers',
              //                   maxLines: 2,
              //                   softWrap: true,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: GoogleFonts.interTight(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.w500,
              //                     color: blackColor,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //       const SizedBox(
              //         height: 10,
              //       ),
              //       CustomButton(
              //         text: 'List a Product',
              //         isFullWidth: true,
              //         onPressed: !user!.emailVerified &&
              //                 user!.providerData[0].providerId == 'password'
              //             ? () => Get.to(
              //                   () => const EmailVerificationScreen(),
              //                 )
              //             : () => onSellButtonClicked(),
              //         icon: Ionicons.bag_add_outline,
              //         bgColor: blueColor,
              //         borderColor: blueColor,
              //         textIconColor: whiteColor,
              //       ),

              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> openProfileImage(BuildContext context) {
    return showDialog(
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
                  scrollPhysics: const BouncingScrollPhysics(),
                  itemCount: 1,
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: CachedNetworkImageProvider(
                        profileImage,
                      ),
                      initialScale: PhotoViewComputedScale.contained * 1,
                      minScale: PhotoViewComputedScale.contained * 1,
                      maxScale: PhotoViewComputedScale.contained * 2,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Ionicons.alert_circle_outline,
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
    );
  }
}

// class MyProfileItemWidget extends StatelessWidget {
//   final Color iconColor;
//   final IconData icon;
//   final String text;
//   final void Function()? onTap;
//   const MyProfileItemWidget({
//     Key? key,
//     required this.iconColor,
//     required this.icon,
//     required this.text,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         splashFactory: InkRipple.splashFactory,
//         splashColor: transparentColor,
//         child: Ink(
//           height: 90,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 15,
//             vertical: 10,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: whiteColor,
//             border: greyBorder,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Icon(
//                 icon,
//                 size: 30,
//                 color: iconColor,
//               ),
//               AutoSizeText(
//                 text,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: true,
//                 style: GoogleFonts.interTight(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
