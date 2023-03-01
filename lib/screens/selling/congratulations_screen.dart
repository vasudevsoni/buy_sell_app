import 'package:buy_sell_app/services/admob_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  late BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    _initBannerAd();
    super.initState();
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: AdmobServices.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: whiteColor,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  '🎉 Congratulations!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.interTight(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: blueColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'We will review your product and then publish it.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.interTight(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: greyColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Note: The review process usually takes 2-3 working hours. In the meantime, browse some products, or just sit back and relax.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                    ),
                  ),
                ),
                const Spacer(),
                _isAdLoaded
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: lightBlackColor,
                            width: 2,
                          ),
                        ),
                        height: 250,
                        width: 300,
                        child: AdWidget(ad: _bannerAd!),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: lightBlackColor,
                            width: 2,
                          ),
                        ),
                        height: 250,
                        width: 300,
                        child: const Center(
                          child: Text('Advertisement'),
                        ),
                      ),
                const Spacer(),
                CustomButton(
                  text: 'Invite your Friends',
                  onPressed: () => Share.share(
                    'Hey! I found some really amazing deals on the BechDe app.\nDownload it now - https://play.google.com/store/apps/details?id=com.bechde.buy_sell_app',
                  ),
                  isFullWidth: true,
                  icon: Ionicons.share_social,
                  bgColor: blackColor,
                  borderColor: blackColor,
                  textIconColor: whiteColor,
                ),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () =>
                      Get.offAll(() => const MainScreen(selectedIndex: 0)),
                  icon: Ionicons.home,
                  isFullWidth: true,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
