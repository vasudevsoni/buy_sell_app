import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/providers.dart';
import '../services/admob_services.dart';
import '../widgets/custom_button_without_icon.dart';
import '/auth/screens/location_screen.dart';
import '/widgets/custom_list_tile_with_subtitle.dart';
import '/services/firebase_services.dart';
import '/auth/screens/landing_screen.dart';
import '/utils/utils.dart';
import 'update_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseServices _services = FirebaseServices();
  final InAppReview inAppReview = InAppReview.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  String address = '';
  String country = '';

  late NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initNativeAd();
  }

  _initNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: AdmobServices.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
          if (mounted) {
            ad.dispose();
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: smallNativeAdStyle,
    );
    // Preload the ad
    await _nativeAd!.load();
  }

  void _fetchUserData() async {
    try {
      final value = await _services.getCurrentUserData();
      if (value['location'] != null && mounted) {
        setState(() {
          address =
              '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}';
          country = value['location']['country'];
        });
      }
    } catch (e) {
      showSnackBar(
        content: 'Error fetching user details. Please try again',
        color: redColor,
      );
    }
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
                Center(
                  child: Text(
                    'Are you sure?',
                    style: GoogleFonts.interTight(
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
                  child: Text(
                    'Are you sure you want to log out of your account? You will need to log in again to access your account.',
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        bgColor: whiteColor,
                        borderColor: greyColor,
                        textIconColor: blackColor,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Log Out',
                        onPressed: () async {
                          Get.back();
                          await FirebaseAuth.instance.signOut().then(
                                (value) => Get.offAll(
                                  () => const LandingScreen(),
                                ),
                              );
                        },
                        bgColor: redColor,
                        borderColor: redColor,
                        textIconColor: whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_nativeAd != null && mounted) {
      _nativeAd!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mainProv = Provider.of<AppNavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.interTight(
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
              child: Text(
                'Account',
                style: GoogleFonts.interTight(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
                  CustomListTileWithSubtitle(
                    text: 'Edit Profile',
                    icon: Ionicons.create_outline,
                    subTitle: 'Edit your name, bio or add social links',
                    trailingIcon: Ionicons.chevron_forward,
                    onTap: () => Get.to(
                      () => const UpdateProfileScreen(),
                    ),
                    isEnabled: true,
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileWithSubtitle(
                    text: 'Change Location',
                    subTitle: address == ''
                        ? 'No location selected'
                        : 'Current location - $address',
                    icon: Ionicons.location_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    onTap: () => Get.to(
                      () => const LocationScreen(
                        isOpenedFromSellButton: false,
                      ),
                    ),
                    isEnabled: true,
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileWithSubtitle(
                    text: 'Unique User Id',
                    subTitle: user!.uid,
                    icon: Ionicons.id_card_outline,
                    onTap: () {},
                    isEnabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                'Actions',
                style: GoogleFonts.interTight(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
                  CustomListTileWithSubtitle(
                    text: 'Participate in our survey',
                    subTitle: 'Help us improve BechDe by filling this survey',
                    icon: Ionicons.flash_outline,
                    textColor: blackColor,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => showSurveyPopUp(context),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileWithSubtitle(
                    text: 'Invite friends to BechDe',
                    subTitle: 'Invite your friends to buy and sell on BechDe',
                    icon: Ionicons.people_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => Share.share(
                        'Hey! I found some really amazing deals on the BechDe app.\nAnd you can also sell products without any listing fees or monthly limits.\nDownload it now - https://play.google.com/store/apps/details?id=com.bechde.buy_sell_app'),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileWithSubtitle(
                    text: 'Log out',
                    subTitle: 'Log out of your account from this device',
                    onTap: showLogoutConfirmation,
                    icon: Ionicons.log_out_outline,
                    textColor: redColor,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: mainProv.adsRemoved
          ? null
          : SmallNativeAd(
              nativeAd: _nativeAd,
              isAdLoaded: _isAdLoaded,
            ),
    );
  }
}
