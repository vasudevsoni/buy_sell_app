import 'package:buy_sell_app/widgets/survey_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../provider/providers.dart';
import '../services/admob_services.dart';
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
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
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
    await _nativeAd!.load();
  }

  @override
  void dispose() {
    if (_nativeAd != null && mounted) {
      _nativeAd!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProv = Provider.of<AppNavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Bio',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                widget.bio,
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SurveyCard(),
            const SizedBox(
              height: 20,
            ),
            if (!mainProv.adsRemoved)
              SmallNativeAd(
                nativeAd: _nativeAd,
                isAdLoaded: _isAdLoaded,
              ),
          ],
        ),
      ),
    );
  }
}
