import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';
import '../widgets/my_listings_list.dart';

class MyListingsScreen extends StatelessWidget {
  static const String routeName = '/my-listings-screen';
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: whiteColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'My Listings',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: const Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: MyListingsList(),
        ),
      ),
    );
  }
}
