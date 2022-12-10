import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../provider/main_provider.dart';
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
import 'update_profile_screen.dart';

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

  final NumberFormat numberFormat = NumberFormat.compact();

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
    final mainProv = Provider.of<MainProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        mainProv.switchToPage(0);
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 150,
                      width: size.width,
                      margin: EdgeInsets.only(bottom: size.width * 0.125),
                      color: greyColor,
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://images.wallpapersden.com/image/download/artistic-5k-mesmerizing-landscape_bWplbmiUmZqaraWkpJRqZmdlrWdtbWU.jpg',
                        filterQuality: FilterQuality.medium,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
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
                    // Positioned(
                    //   top: 10,
                    //   right: 10,
                    //   child: ActionChip(
                    //     onPressed: () {},
                    //     backgroundColor: blueColor,
                    //     avatar: const Icon(
                    //       Ionicons.diamond,
                    //       color: whiteColor,
                    //     ),
                    //     label: const Text(
                    //       '200 coins',
                    //       style: TextStyle(
                    //         color: whiteColor,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    profileImage == ''
                        ? Positioned(
                            top: 150 - (size.width * 0.125),
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
                            ),
                          )
                        : Positioned(
                            top: 150 - (size.width * 0.125),
                            child: GestureDetector(
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                                              duration:
                                                  Duration(milliseconds: 1000),
                                            ),
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
                                          () =>
                                              const UpdateProfileImageScreen(),
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
                    style: const TextStyle(
                      color: blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                      style: const TextStyle(
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
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomButton(
                    text: 'Edit Profile',
                    onPressed: () => Get.to(
                      () => const UpdateProfileScreen(),
                    ),
                    icon: Ionicons.create_outline,
                    bgColor: whiteColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomButton(
                    text: 'Sell a Product',
                    onPressed: !user!.emailVerified &&
                            user!.providerData[0].providerId == 'password'
                        ? () => Get.to(
                              () => const EmailVerificationScreen(),
                            )
                        : onSellButtonClicked,
                    icon: Ionicons.bag_add,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      MyProfileItemWidget(
                        icon: Ionicons.list,
                        text: 'My Products',
                        onTap: () => Get.to(
                          () => const MyListingsScreen(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      MyProfileItemWidget(
                        icon: Ionicons.cog,
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
                        iconColor: blackColor,
                        icon: Ionicons.headset,
                        text: 'Help & Support',
                        onTap: () => Get.to(
                          () => const HelpAndSupportScreen(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      MyProfileItemWidget(
                        icon: Ionicons.star,
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
                          const Text(
                            'Made with ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: lightBlackColor,
                            ),
                          ),
                          Icon(
                            Ionicons.heart,
                            color: redColor,
                            size: iconSize.toDouble(),
                          ),
                          const Text(
                            ' in India',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: lightBlackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyProfileItemWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final Color? iconColor;
  const MyProfileItemWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
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
                style: const TextStyle(
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
