import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';
import '../widgets/my_favorites_products_list.dart';

class MyFavoritesScreen extends StatelessWidget {
  static const String routeName = '/selling-screen';
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Row(
                  children: [
                    Text(
                      'My Favorites',
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      FontAwesomeIcons.solidHeart,
                      color: pinkColor,
                    ),
                  ],
                ),
              ),
              const MyFavoritesProductsList(),
            ],
          ),
        ),
      ),
    );
  }
}
