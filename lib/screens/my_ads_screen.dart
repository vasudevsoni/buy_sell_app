import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/my_ads_screen_products_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAdsScreen extends StatelessWidget {
  static const String routeName = '/selling-screen';
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0.2,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            'My Ads',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          bottom: TabBar(
            indicatorColor: blueColor,
            indicatorWeight: 4,
            isScrollable: false,
            tabs: [
              Tab(
                child: Text(
                  'Selling',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Favorites',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 15,
                    ),
                    child: Text(
                      'My Products',
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const MyAdsScreenProductsList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'My Favorites',
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
