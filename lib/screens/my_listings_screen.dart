import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/my_products_list.dart';

class MyListingsScreen extends StatelessWidget {
  static const String routeName = '/my-listings-screen';
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'My Listings',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: const Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: MyProductsList(),
        ),
      ),
    );
  }
}
