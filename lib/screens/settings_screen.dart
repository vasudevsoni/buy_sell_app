import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_redirect/store_redirect.dart';

import '../widgets/custom_button_without_icon.dart';
import '/auth/screens/location_screen.dart';
import '/widgets/custom_list_tile_with_subtitle.dart';
import '/services/firebase_services.dart';
import '/auth/screens/landing_screen.dart';
import '/utils/utils.dart';

class SettingsScreen extends StatefulWidget {
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
    if (!mounted) {
      return;
    }
    _services.getCurrentUserData().then((value) {
      if (value['location'] == null) {
        return;
      }
      setState(() {
        address =
            '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}';
        country = value['location']['country'];
      });
    });
    setState(() {
      signInMethod = user!.providerData[0].providerId.toString();
    });
    super.initState();
  }

  showLogoutConfirmation() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                const Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greyColor,
                  ),
                  child: const Text(
                    'Are you sure you want to log out of your account? You will need to log in again to access your account.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Yes, Log Out',
                  onPressed: () async {
                    Get.back();
                    await FirebaseAuth.instance.signOut().then(
                          (value) => Get.off(
                            () => const LandingScreen(),
                          ),
                        );
                  },
                  bgColor: whiteColor,
                  borderColor: redColor,
                  textIconColor: redColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'No, Cancel',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: const Text(
                'Account',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Location',
              subTitle: address == '' ? 'No location selected' : address,
              icon: FontAwesomeIcons.locationDot,
              trailingIcon: FontAwesomeIcons.chevronRight,
              onTap: () => Get.to(
                () => const LocationScreen(
                  isOpenedFromSellButton: false,
                ),
              ),
              isEnabled: true,
            ),
            if (signInMethod == 'phone')
              CustomListTileWithSubtitle(
                text: 'Signed in using',
                subTitle: 'Mobile Number',
                icon: FontAwesomeIcons.rightToBracket,
                isEnabled: false,
                onTap: () {},
              ),
            if (signInMethod == 'google.com')
              CustomListTileWithSubtitle(
                text: 'Logged in using',
                subTitle: 'Google',
                icon: FontAwesomeIcons.rightToBracket,
                isEnabled: false,
                onTap: () {},
              ),
            if (signInMethod == 'password')
              CustomListTileWithSubtitle(
                text: 'Logged in using',
                subTitle: 'Email Address',
                icon: FontAwesomeIcons.rightToBracket,
                isEnabled: false,
                onTap: () {},
              ),
            CustomListTileWithSubtitle(
              text: 'Unique User Id',
              subTitle: user!.uid,
              icon: FontAwesomeIcons.idBadge,
              onTap: () {},
              isEnabled: false,
            ),
            const Divider(
              height: 0,
              indent: 15,
              color: lightBlackColor,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: const Text(
                'Actions',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Rate us on Play Store',
              subTitle:
                  'If you love our app, please take a moment to rate it on the Play Store',
              icon: FontAwesomeIcons.solidStar,
              textColor: blueColor,
              trailingIcon: FontAwesomeIcons.chevronRight,
              isEnabled: true,
              onTap: () {
                StoreRedirect.redirect();
              },
            ),
            CustomListTileWithSubtitle(
              text: 'Invite friends to BestDeal',
              subTitle: 'Invite your friends to buy and sell',
              icon: FontAwesomeIcons.users,
              trailingIcon: FontAwesomeIcons.chevronRight,
              isEnabled: true,
              onTap: () {
                Share.share(
                    'I found some amazing deals on the BestDeal app. Download it now - https://play.google.com/store/apps/details?id=com.vasudevsoni.buy_sell_app');
              },
            ),
            CustomListTileWithSubtitle(
              text: 'Log out',
              subTitle: 'Log out of your account from this device',
              onTap: showLogoutConfirmation,
              icon: FontAwesomeIcons.rightFromBracket,
              trailingIcon: FontAwesomeIcons.chevronRight,
              isEnabled: true,
            ),
            const Divider(
              height: 0,
              indent: 15,
              color: lightBlackColor,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: const Text(
                'Danger Zone',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Delete account',
              subTitle: 'This will delete all your data',
              onTap: () {},
              textColor: redColor,
              icon: FontAwesomeIcons.trash,
              trailingIcon: FontAwesomeIcons.chevronRight,
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
