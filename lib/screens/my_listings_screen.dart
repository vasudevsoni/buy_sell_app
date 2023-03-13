import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/admob_services.dart';
import '/utils/utils.dart';
import '/widgets/my_listings_list.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  @override
  void initState() {
    _initBannerAd();
    super.initState();
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.largeBanner,
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
        automaticallyImplyLeading: true,
        backgroundColor: whiteColor,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'My listings',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: const MyListingsList(),
      bottomNavigationBar: _isAdLoaded
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: greyColor,
                  width: 1,
                ),
              ),
              height: 100,
              width: 320,
              child: AdWidget(ad: _bannerAd!),
            )
          : Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: greyColor,
                  width: 1,
                ),
              ),
              height: 100,
              width: 320,
              child: const Center(
                child: Text('Advertisement'),
              ),
            ),
    );
  }
}
