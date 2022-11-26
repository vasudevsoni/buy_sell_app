import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;
  String signInMethod = '';
  String address = '';
  String country = '';

  @override
  void initState() {
    _services.getCurrentUserData().then((value) {
      if (value['location'] != null && mounted) {
        setState(() {
          address =
              '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}';
          country = value['location']['country'];
        });
      }
    });
    if (mounted) {
      setState(() {
        signInMethod = user!.providerData[0].providerId.toString();
      });
    }
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
                const Center(
                  child: Text(
                    'Are you sure?',
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
                          (value) => Get.offAll(
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
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
              width: size.width,
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
              icon: Ionicons.location,
              trailingIcon: Ionicons.chevron_forward,
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
                icon: Ionicons.log_in,
                isEnabled: false,
                onTap: () {},
              ),
            if (signInMethod == 'google.com')
              CustomListTileWithSubtitle(
                text: 'Logged in using',
                subTitle: 'Google',
                icon: Ionicons.log_in,
                isEnabled: false,
                onTap: () {},
              ),
            if (signInMethod == 'password')
              CustomListTileWithSubtitle(
                text: 'Logged in using',
                subTitle: 'Email Address',
                icon: Ionicons.log_in,
                isEnabled: false,
                onTap: () {},
              ),
            CustomListTileWithSubtitle(
              text: 'Unique User Id',
              subTitle: user!.uid,
              icon: Ionicons.id_card,
              onTap: () {},
              isEnabled: false,
            ),
            const Divider(
              height: 0,
              indent: 15,
              color: lightBlackColor,
            ),
            Container(
              width: size.width,
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
              icon: Ionicons.star,
              textColor: blueColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () {
                StoreRedirect.redirect();
              },
            ),

            CustomListTileWithSubtitle(
              text: 'Invite friends to BechDe',
              subTitle: 'Invite your friends to buy and sell on BechDe',
              icon: Ionicons.people,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () {
                Share.share(
                    'Hey! I found some really amazing deals on the BechDe app. Download it now - https://play.google.com/store/apps/details?id=com.bechde.buy_sell_app');
              },
            ),
            CustomListTileWithSubtitle(
              text: 'Log out',
              subTitle: 'Log out of your account from this device',
              onTap: showLogoutConfirmation,
              icon: Ionicons.log_out,
              textColor: redColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
            ),
            // const Divider(
            //   height: 0,
            //   indent: 15,
            //   color: lightBlackColor,
            // ),
            // Container(
            //   width: size.width,
            //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            //   child: const Text(
            //     'Danger Zone',
            //     style: TextStyle(
            //       color: blackColor,
            //       fontSize: 18,
            //       fontWeight: FontWeight.w700,
            //     ),
            //   ),
            // ),
            // CustomListTileWithSubtitle(
            //   text: 'Delete account',
            //   subTitle: 'This will delete all your data',
            //   onTap: () {},
            //   textColor: redColor,
            //   icon: FontAwesomeIcons.trash,
            //   trailingIcon: Ionicons.chevron_forward,
            //   isEnabled: true,
            // ),
          ],
        ),
      ),
    );
  }
}
