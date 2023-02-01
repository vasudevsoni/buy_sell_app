import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ionicons/ionicons.dart';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Product images',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 6,
              );
            },
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
                        PageController pageController =
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
                                          Ionicons.alert_circle,
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
                                    splashColor: blueColor,
                                    splashRadius: 30,
                                    icon: const Icon(
                                      Ionicons.close_circle_outline,
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
                        color: blackColor,
                        width: double.infinity,
                        height: size.height * 0.25,
                        child: CachedNetworkImage(
                          imageUrl: widget.images[index],
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          memCacheHeight: (size.height * 0.25).round(),
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Ionicons.alert_circle,
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
                    left: 15,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        shadows: [
                          Shadow(
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
