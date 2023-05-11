import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../services/admob_services.dart';
import '../widgets/custom_loading_indicator.dart';
import '/utils/utils.dart';

class AllImagesDisplayScreen extends StatefulWidget {
  final List images;
  const AllImagesDisplayScreen({super.key, required this.images});

  @override
  State<AllImagesDisplayScreen> createState() => _AllImagesDisplayScreenState();
}

class _AllImagesDisplayScreenState extends State<AllImagesDisplayScreen> {
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
  //     size: AdSize.largeBanner,
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Images',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      bottomNavigationBar: SmallNativeAd(
        nativeAd: _nativeAd,
        isAdLoaded: _isAdLoaded,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: widget.images.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) {
                        final pageController =
                            PageController(initialPage: index);
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.down,
                          onDismissed: (direction) {
                            pageController.dispose();
                            Get.back();
                          },
                          child: Material(
                            color: blackColor,
                            child: Stack(
                              children: [
                                PhotoViewGallery.builder(
                                  scrollPhysics: const ClampingScrollPhysics(),
                                  itemCount: widget.images.length,
                                  pageController: pageController,
                                  builder: (BuildContext context, int index) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider: CachedNetworkImageProvider(
                                        widget.images[index],
                                      ),
                                      initialScale:
                                          PhotoViewComputedScale.contained * 1,
                                      minScale:
                                          PhotoViewComputedScale.contained * 1,
                                      maxScale:
                                          PhotoViewComputedScale.contained * 10,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          MdiIcons.alertDecagramOutline,
                                          size: 20,
                                          color: redColor,
                                        );
                                      },
                                    );
                                  },
                                  loadingBuilder: (context, event) {
                                    return const Center(
                                      child: CustomLoadingIndicator(),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 15,
                                  right: 15,
                                  child: IconButton(
                                    onPressed: () {
                                      pageController.dispose();
                                      Get.back();
                                    },
                                    splashColor: transparentColor,
                                    splashRadius: 30,
                                    icon: const Icon(
                                      MdiIcons.closeCircleOutline,
                                      size: 30,
                                      color: whiteColor,
                                      shadows: [
                                        BoxShadow(
                                          offset: Offset(0, 0),
                                          blurRadius: 15,
                                          spreadRadius: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: blackColor,
                        ),
                        width: double.infinity,
                        height: size.height * 0.25,
                        child: CachedNetworkImage(
                          imageUrl: widget.images[index],
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          memCacheHeight: (size.height * 0.25).round(),
                          errorWidget: (context, url, error) {
                            return const Icon(
                              MdiIcons.alertDecagramOutline,
                              size: 30,
                              color: redColor,
                            );
                          },
                          placeholder: (context, url) {
                            return const Center(
                              child: CustomLoadingIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Text(
                      index == 0 ? 'Cover' : '${index + 1}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w900,
                        fontSize: 27,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 10.0,
                            color: lightBlackColor,
                          ),
                        ],
                        color: whiteColor,
                      ),
                    ),
                  ),
                ],
              );
            },
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
