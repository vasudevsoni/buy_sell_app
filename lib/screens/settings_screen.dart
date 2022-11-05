import 'package:buy_sell_app/auth/screens/location_screen.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/screens/landing_screen.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_list_tile_no_image.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings-screen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseServices _services = FirebaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  String signInMethod = '';
  String address = '';
  String country = '';

  @override
  void initState() {
    if (mounted) {
      _services.getCurrentUserData().then((value) {
        if (value['location'] == null) {
          return;
        } else {
          setState(() {
            address =
                '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}';
            country = value['location']['country'];
          });
        }
      });
      setState(() {
        signInMethod = user!.providerData[0].providerId.toString();
      });
    }
    super.initState();
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
          'Settings',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'Account',
                  style: GoogleFonts.poppins(
                    color: blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => const LocationScreen(isOpenedFromSellButton: false),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 15,
                    right: 15,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  width: MediaQuery.of(context).size.width,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: greyColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        address == '' ? 'No location selected' : address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: lightBlackColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: 15,
                  right: 15,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: greyColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nationality',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      country == '' ? 'No location selected' : country,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: lightBlackColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (signInMethod == 'phone')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomListTileNoImage(
                    text: 'Signed in using',
                    icon: FontAwesomeIcons.phone,
                    onTap: () {},
                  ),
                ),
              if (signInMethod == 'google.com')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomListTileNoImage(
                    text: 'Signed in using',
                    icon: FontAwesomeIcons.google,
                    onTap: () {},
                  ),
                ),
              if (signInMethod == 'password')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomListTileNoImage(
                    text: 'Signed in using',
                    icon: FontAwesomeIcons.solidEnvelope,
                    onTap: () {},
                  ),
                ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'Support',
                  style: GoogleFonts.poppins(
                    color: blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'Help & Support',
                  icon: FontAwesomeIcons.headset,
                  onTap: () {},
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'About',
                  style: GoogleFonts.poppins(
                    color: blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'Terms & Conditions',
                  icon: FontAwesomeIcons.bookOpen,
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'Privacy',
                  icon: FontAwesomeIcons.lock,
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTileNoImage(
                  text: 'Version - 1.0.0',
                  icon: FontAwesomeIcons.mobile,
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CustomButton(
                  text: 'Log out',
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      Get.offNamed(LandingScreen.routeName);
                    });
                  },
                  icon: FontAwesomeIcons.rightFromBracket,
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
