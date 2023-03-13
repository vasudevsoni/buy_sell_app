import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/admob_services.dart';
import '../../widgets/custom_loading_indicator.dart';
import '/screens/category_products_screen.dart';
import '/widgets/custom_list_tile_no_image.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';

class SubCategoriesListScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const SubCategoriesListScreen({
    super.key,
    required this.doc,
  });

  @override
  State<SubCategoriesListScreen> createState() =>
      _SubCategoriesListScreenState();
}

class _SubCategoriesListScreenState extends State<SubCategoriesListScreen> {
  final FirebaseServices service = FirebaseServices();
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
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          widget.doc['catName'],
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<DocumentSnapshot>(
          stream: service.categories.doc(widget.doc.id).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Erorr loading sub-categories'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: CustomLoadingIndicator(),
                ),
              );
            }
            var data = snapshot.data!['subCat'];
            return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 0,
                  color: fadedColor,
                  indent: 15,
                  endIndent: 15,
                );
              },
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return CustomListTileNoImage(
                  text: data[index],
                  trailingIcon: MdiIcons.chevronRight,
                  isEnabled: true,
                  onTap: () => Get.to(
                    () => CategoryProductsScreen(
                      catName: widget.doc['catName'],
                      subCatName: data[index],
                    ),
                  ),
                );
              },
            );
          },
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
    );
  }
}
