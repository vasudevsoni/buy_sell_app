import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../services/admob_services.dart';
import '../widgets/custom_button_without_icon.dart';
import '/utils/utils.dart';

class FullBioScreen extends StatefulWidget {
  final String bio;
  const FullBioScreen({
    super.key,
    required this.bio,
  });

  @override
  State<FullBioScreen> createState() => _FullBioScreenState();
}

class _FullBioScreenState extends State<FullBioScreen> {
  late NativeAd? _nativeAd;
  // late BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initNativeAd();
    // _initBannerAd();
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

  // _initBannerAd() {
  //   _bannerAd = BannerAd(
  //     size: AdSize.mediumRectangle,
  //     adUnitId: AdmobServices.bannerAdUnitId,
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         setState(() {
  //           _isAdLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         setState(() {
  //           _isAdLoaded = false;
  //         });
  //         if (mounted) {
  //           ad.dispose();
  //         }
  //       },
  //     ),
  //     request: const AdRequest(),
  //   );
  //   // Preload the ad
  //   _bannerAd!.load();
  // }

  @override
  void dispose() {
    if (_nativeAd != null && mounted) {
      _nativeAd!.dispose();
    }
    // if (_bannerAd != null && mounted) {
    //   _bannerAd!.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Bio',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.bio,
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: whiteColor,
                  border: greyBorder,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              MdiIcons.robotHappyOutline,
                              color: greenColor,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Participate in our survey',
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                                color: blackColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: AutoSizeText(
                            'Help us improve BechDe by filling this survey.',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.interTight(
                              fontWeight: FontWeight.w500,
                              color: blackColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustomButtonWithoutIcon(
                      text: 'Let\'s go',
                      onPressed: () => showSurveyPopUp(context),
                      borderColor: blueColor,
                      bgColor: blueColor,
                      textIconColor: whiteColor,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SmallNativeAd(
                    nativeAd: _nativeAd,
                    isAdLoaded: _isAdLoaded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
