import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';

import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/screens/main_screen.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  final InAppReview inAppReview = InAppReview.instance;
  // bool showAd = true;

  // Future<void> _initInterstitialAd() async {
  //   try {
  //     await InterstitialAd.load(
  //       adUnitId: AdmobServices.interstitialAdUnitId,
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           ad.fullScreenContentCallback = FullScreenContentCallback(
  //             onAdFailedToShowFullScreenContent: (ad, err) {
  //               setState(() {
  //                 showAd = false;
  //               });
  //               ad.dispose();
  //             },
  //             onAdDismissedFullScreenContent: (ad) {
  //               ad.dispose();
  //             },
  //           );
  //           ad.show();
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           setState(() {
  //             showAd = false;
  //           });
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() {
  //       showAd = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final mainProv = Provider.of<AppNavigationProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  '🎉 Well Done! 🎉',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: blueColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Your listing is under review',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: blackColor,
                    border: greyBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Note: Review usually takes up to 24 hours to complete.\nMay take longer during weekends or holidays when our team is not fully staffed.\nThank you for your patience.',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: whiteColor,
                    ),
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () => Get.offAll(
                    () => const MainScreen(selectedIndex: 0),
                  )
                  // if (showAd && !mainProv.adsRemoved) {
                  //   await _initInterstitialAd();
                  // }
                  ,
                  icon: Ionicons.home_outline,
                  isFullWidth: true,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
                CustomButton(
                  text: 'Share with Friends',
                  onPressed: () => Share.share(
                      'Hey! I found some really amazing deals on the BechDe app.\nAnd you can also sell products without any listing fees or monthly limits.\nDownload it now - https://play.google.com/store/apps/details?id=com.bechde.buy_sell_app'),
                  isFullWidth: true,
                  icon: Ionicons.share_social_outline,
                  bgColor: blackColor,
                  borderColor: blackColor,
                  textIconColor: whiteColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
