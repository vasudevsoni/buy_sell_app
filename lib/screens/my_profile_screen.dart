import 'package:animations/animations.dart';
import 'package:buy_sell_app/auth/screens/email_verification_screen.dart';
import 'package:buy_sell_app/auth/screens/location_screen.dart';
import 'package:buy_sell_app/screens/my_listings_screen.dart';
import 'package:buy_sell_app/screens/selling/seller_categories_list_screen.dart';
import 'package:buy_sell_app/screens/settings_screen.dart';
import 'package:buy_sell_app/screens/update_profile_image_screen.dart';
import 'package:buy_sell_app/screens/update_profile_screen.dart';
import 'package:buy_sell_app/widgets/custom_list_tile_no_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../services/firebase_services.dart';

class MyProfileScreen extends StatefulWidget {
  static const String routeName = '/my-profile-screen';
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
    if (mounted) {
      setState(() {
        getUserData();
      });
    }
    super.initState();
  }

  getUserData() async {
    await services.getCurrentUserData().then((value) {
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
          dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
        });
      }
    });
  }

  onSellButtonClicked() {
    services.getCurrentUserData().then((value) {
      if (value['location'] == null) {
        Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
        showSnackBar(
          context: context,
          content: 'Please set your location to sell an item',
          color: redColor,
        );
      } else {
        Get.toNamed(SellerCategoriesListScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: RefreshIndicator(
            onRefresh: () {
              Get.reload();
              return Future.delayed(const Duration(seconds: 2));
            },
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
                              onTap: () {
                                showModal(
                                  configuration:
                                      const FadeScaleTransitionConfiguration(),
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
                                            Positioned(
                                              top: 20,
                                              right: 20,
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  Get.back();
                                                  Get.toNamed(
                                                      UpdateProfileImageScreen
                                                          .routeName);
                                                },
                                                child: Text(
                                                  'Edit',
                                                  style: GoogleFonts.poppins(
                                                    color: whiteColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
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
                                                  minScale:
                                                      PhotoViewComputedScale
                                                              .contained *
                                                          1,
                                                  maxScale:
                                                      PhotoViewComputedScale
                                                              .contained *
                                                          2,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
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
                                            Positioned(
                                              top: 20,
                                              right: 20,
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  Get.back();
                                                  Get.toNamed(
                                                      UpdateProfileImageScreen
                                                          .routeName);
                                                },
                                                child: Text(
                                                  'Edit',
                                                  style: GoogleFonts.poppins(
                                                    color: whiteColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
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
                                          duration:
                                              Duration(milliseconds: 1000),
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
                                style: GoogleFonts.poppins(
                                  color: blackColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (bio != '')
                                Text(
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
                            ],
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Get.toNamed(UpdateProfileScreen.routeName);
                          },
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
                    height: 20,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: CustomButton(
                      text: 'Sell a product',
                      onPressed: !user!.emailVerified &&
                              user!.providerData[0].providerId == 'password'
                          ? () {
                              Get.toNamed(EmailVerificationScreen.routeName);
                            }
                          : onSellButtonClicked,
                      icon: FontAwesomeIcons.plus,
                      bgColor: blueColor,
                      borderColor: blueColor,
                      textIconColor: whiteColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomListTileNoImage(
                      text: 'My Listings',
                      icon: FontAwesomeIcons.list,
                      onTap: () {
                        Get.toNamed(MyListingsScreen.routeName);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomListTileNoImage(
                      text: 'Settings',
                      icon: FontAwesomeIcons.gear,
                      onTap: () {
                        Get.toNamed(SettingsScreen.routeName);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Made with ❤️ in India',
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
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
      ),
    );
  }
}
