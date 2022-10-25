import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';

class FullBioScreen extends StatelessWidget {
  final String bio;
  const FullBioScreen({
    super.key,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Bio',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Hero(
            tag: 'full-bio',
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                bio,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
