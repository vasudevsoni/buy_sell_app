import 'package:buy_sell_app/services/admob_services.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
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
  final ConfettiController controller = ConfettiController();
  late BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    _initBannerAd();
    controller.play();
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
    controller.dispose();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomConfettiWidget(
                      controller: controller,
                      blastDirection: 225,
                    ),
                    CustomConfettiWidget(
                      controller: controller,
                      blastDirection: 180,
                    ),
                  ],
                ),
                const Text(
                  '👍',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: blueColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: blueColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Your product will be live once it is reviewed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                ),
                const Text(
                  'In the meantime, browse some products, or just sit back and relax.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
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
                const SizedBox(
                  height: 5,
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

class CustomConfettiWidget extends StatelessWidget {
  const CustomConfettiWidget({
    Key? key,
    required this.controller,
    required this.blastDirection,
  }) : super(key: key);

  final ConfettiController controller;
  final double blastDirection;

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,
      shouldLoop: false,
      colors: const [
        blueColor,
        redColor,
        Colors.blue,
        Colors.yellow,
      ],
      blastDirectionality: BlastDirectionality.directional,
      emissionFrequency: 0.01,
      maxBlastForce: 50,
      minBlastForce: 10,
      blastDirection: blastDirection,
      minimumSize: const Size(10, 10),
      maximumSize: const Size(50, 50),
      numberOfParticles: 10,
      gravity: 0.1,
    );
  }
}
