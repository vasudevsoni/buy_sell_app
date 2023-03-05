import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ionicons/ionicons.dart';

import '../../services/admob_services.dart';
import '../../widgets/custom_loading_indicator.dart';
import '/utils/utils.dart';
import '/widgets/custom_list_tile_no_image.dart';
import '/services/firebase_services.dart';
import 'common/ad_post_screen.dart';
import 'jobs/job_ad_post_screen.dart';
import 'vehicles/vehicle_ad_post_screen.dart';

class SellerSubCategoriesListScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const SellerSubCategoriesListScreen({
    super.key,
    required this.doc,
  });

  @override
  State<SellerSubCategoriesListScreen> createState() =>
      _SellerSubCategoriesListScreenState();
}

class _SellerSubCategoriesListScreenState
    extends State<SellerSubCategoriesListScreen> {
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
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Select a sub category in ${widget.doc['catName']}',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SizedBox(
        height: size.height,
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
                  trailingIcon: Ionicons.chevron_forward,
                  isEnabled: true,
                  onTap: () {
                    if (widget.doc['catName'] == 'Vehicles') {
                      Get.offAll(
                        () => VehicleAdPostScreen(subCatName: data[index]),
                        transition: Transition.downToUp,
                      );
                      return;
                    } else if (widget.doc['catName'] == 'Jobs') {
                      Get.offAll(
                        () => JobAdPostScreen(subCatName: data[index]),
                        transition: Transition.downToUp,
                      );
                      return;
                    }
                    Get.offAll(
                      () => AdPostScreen(
                          catName: widget.doc['catName'],
                          subCatName: data[index]),
                      transition: Transition.downToUp,
                    );
                  },
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
