import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/admob_services.dart';
import '/utils/utils.dart';

class FullDescriptionScreen extends StatefulWidget {
  final String desc;
  const FullDescriptionScreen({
    super.key,
    required this.desc,
  });

  @override
  State<FullDescriptionScreen> createState() => _FullDescriptionScreenState();
}

class _FullDescriptionScreenState extends State<FullDescriptionScreen> {
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
          if (mounted) {
            ad.dispose();
          }
        },
      ),
      request: const AdRequest(),
    );
    // Preload the ad
    _bannerAd!.load();
  }

  @override
  void dispose() {
    if (_bannerAd != null && mounted) {
      _bannerAd!.dispose();
    }
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
          'Description',
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
                widget.desc,
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              _isAdLoaded
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: lightBlackColor,
                              width: 2,
                            ),
                          ),
                          height: 250,
                          width: 300,
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
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
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
