import 'package:buy_sell_app/screens/my_listings_screen.dart';
import 'package:buy_sell_app/screens/settings_screen.dart';
import 'package:buy_sell_app/screens/update_profile_image_screen.dart';
import 'package:buy_sell_app/screens/update_profile_screen.dart';
import 'package:buy_sell_app/widgets/custom_list_tile_no_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import 'landing_screen.dart';
import '../services/firebase_services.dart';

class MyProfileScreen extends StatefulWidget {
  static const String routeName = '/my-profile-screen';
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final FirebaseServices services = FirebaseServices();
  String name = '';
  String profileImage = '';
  String bio = '';
  DateTime dateJoined = DateTime.now();

  @override
  void initState() {
    setState(() {
      getUserData();
    });
    super.initState();
  }

  getUserData() async {
    await services.getCurrentUserData().then((value) {
      if (mounted) {
        setState(() {
          if (value['name'] == null) {
            name = 'Name will show here';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'My Profile',
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
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
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dismissible(
                                  key: const Key('photoKey'),
                                  direction: DismissDirection.down,
                                  onDismissed: (direction) {
                                    Navigator.pop(context);
                                  },
                                  child: Material(
                                    color: Colors.black,
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
                                              Iconsax.security_user4,
                                              color: Colors.white,
                                              size: 80,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 15,
                                          left: 15,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            splashColor: blueColor,
                                            splashRadius: 30,
                                            icon: const Icon(
                                              Iconsax.close_square4,
                                              size: 30,
                                              color: Colors.white,
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
                                              Navigator.pop(context);
                                              Navigator.of(context).pushNamed(
                                                UpdateProfileImageScreen
                                                    .routeName,
                                              );
                                            },
                                            child: Text(
                                              'Edit',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
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
                              Iconsax.security_user4,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dismissible(
                                  key: const Key('photoKey'),
                                  direction: DismissDirection.down,
                                  onDismissed: (direction) {
                                    Navigator.pop(context);
                                  },
                                  child: Material(
                                    color: Colors.black,
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
                                                  Iconsax.warning_24,
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
                                              Navigator.pop(context);
                                            },
                                            splashColor: blueColor,
                                            splashRadius: 30,
                                            icon: const Icon(
                                              Iconsax.close_square4,
                                              size: 30,
                                              color: Colors.white,
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
                                              Navigator.pop(context);
                                              Navigator.of(context).pushNamed(
                                                UpdateProfileImageScreen
                                                    .routeName,
                                              );
                                            },
                                            child: Text(
                                              'Edit',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            PageTransition(
                              child: const UpdateProfileScreen(),
                              type: PageTransitionType.rightToLeftWithFade,
                            ),
                          );
                        },
                        child: const Icon(
                          Iconsax.message_edit5,
                          size: 25,
                          color: fadedColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'My Listings',
                  icon: Iconsax.category5,
                  onTap: () {
                    Navigator.of(context).pushNamed(MyListingsScreen.routeName);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'Settings',
                  icon: Iconsax.setting_45,
                  onTap: () {
                    Navigator.pushNamed(context, SettingsScreen.routeName);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'Help & Support',
                  icon: Iconsax.headphone5,
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CustomButton(
                  text: 'Log out',
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.pushReplacementNamed(
                        context,
                        LandingScreen.routeName,
                      );
                    });
                  },
                  icon: Iconsax.logout4,
                  bgColor: blackColor,
                  borderColor: blackColor,
                  textIconColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
