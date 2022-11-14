import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/auth/screens/email_verification_screen.dart';
import '/auth/screens/location_screen.dart';
import 'help_and_support_screen.dart';
import 'my_listings_screen.dart';
import '/screens/selling/seller_categories_list_screen.dart';
import 'settings_screen.dart';
import 'update_profile_image_screen.dart';
import 'update_profile_screen.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;
  String name = '';
  String profileImage = '';
  String bio = '';

  DateTime dateJoined = DateTime.now();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await services.getCurrentUserData().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (value['name'] == 'BestDeal User') {
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
        dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
      });
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
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 20,
                    ),
                    child: profileImage == ''
                        ? GestureDetector(
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
                                        Center(
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .width,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: blueColor,
                                            child: const Icon(
                                              FontAwesomeIcons.userTie,
                                              color: whiteColor,
                                              size: 150,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 15,
                                          left: 15,
                                          child: IconButton(
                                            onPressed: () => Get.back(),
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
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              Get.back();
                                              Get.to(
                                                () =>
                                                    const UpdateProfileImageScreen(),
                                              );
                                            },
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: whiteColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                              height: MediaQuery.of(context).size.width * 0.3,
                              width: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: blueColor,
                              ),
                              child: const Icon(
                                FontAwesomeIcons.userTie,
                                color: whiteColor,
                                size: 50,
                              ),
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
                                              child: SpinKitFadingCircle(
                                                color: greyColor,
                                                size: 20,
                                                duration: Duration(
                                                    milliseconds: 1000),
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 15,
                                          left: 15,
                                          child: IconButton(
                                            onPressed: () => Get.back(),
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
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              Get.back();
                                              Get.to(
                                                () =>
                                                    const UpdateProfileImageScreen(),
                                              );
                                            },
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: whiteColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: blackColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (bio != '')
                              const SizedBox(
                                height: 5,
                              ),
                            if (bio != '')
                              Text(
                                bio,
                                maxLines: 3,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: blackColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.to(
                          () => const UpdateProfileScreen(),
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            FontAwesomeIcons.solidPenToSquare,
                            size: 25,
                            color: lightBlackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Joined ${timeago.format(dateJoined)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      color: lightBlackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
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
                    icon: FontAwesomeIcons.plus,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
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
                        icon: FontAwesomeIcons.listUl,
                        text: 'My Products',
                        onTap: () => Get.to(
                          () => const MyListingsScreen(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      MyProfileItemWidget(
                        icon: FontAwesomeIcons.userGear,
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
                        icon: FontAwesomeIcons.headset,
                        text: 'Help and Support',
                        onTap: () => Get.to(
                          () => const HelpAndSupportScreen(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      MyProfileItemWidget(
                        icon: FontAwesomeIcons.solidStar,
                        iconColor: blueColor,
                        text: 'Rate us',
                        onTap: () {
                          StoreRedirect.redirect();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Made in India 🇮🇳',
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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
            color: greyColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                size: 22,
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
