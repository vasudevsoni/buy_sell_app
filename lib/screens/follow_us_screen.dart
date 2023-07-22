import 'package:buy_sell_app/widgets/custom_list_tile_no_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/providers.dart';
import '../services/admob_services.dart';
import '/utils/utils.dart';

class FollowUsScreen extends StatefulWidget {
  const FollowUsScreen({super.key});

  @override
  State<FollowUsScreen> createState() => _FollowUsScreenState();
}

class _FollowUsScreenState extends State<FollowUsScreen> {
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
    // Preload the ad
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
          'Follow Us',
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
          children: [
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                'Our Social Media',
                style: GoogleFonts.sora(
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
                  CustomListTileNoImage(
                    text: 'Facebook',
                    icon: Ionicons.logo_facebook,
                    trailingIcon: Ionicons.chevron_forward,
                    onTap: () => launchUrl(
                      Uri.parse(
                          'https://www.facebook.com/profile.php?id=100088872034817'),
                      mode: LaunchMode.externalApplication,
                    ),
                    isEnabled: true,
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Instagram',
                    icon: Ionicons.logo_instagram,
                    trailingIcon: Ionicons.chevron_forward,
                    onTap: () => launchUrl(
                      Uri.parse('https://www.instagram.com/bechdeofficial/'),
                      mode: LaunchMode.externalApplication,
                    ),
                    isEnabled: true,
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Twitter',
                    icon: Ionicons.logo_twitter,
                    trailingIcon: Ionicons.chevron_forward,
                    onTap: () => launchUrl(
                      Uri.parse('https://twitter.com/BechDeOfficial'),
                      mode: LaunchMode.externalApplication,
                    ),
                    isEnabled: true,
                  ),
                ],
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
    );
  }
}
