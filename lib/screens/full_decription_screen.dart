import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../provider/providers.dart';
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
      nativeTemplateStyle: mediumNativeAdStyle,
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
          'Full description',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(
                height: 20,
              ),
              if (!mainProv.adsRemoved)
                MediumNativeAd(
                  nativeAd: _nativeAd,
                  isAdLoaded: _isAdLoaded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
