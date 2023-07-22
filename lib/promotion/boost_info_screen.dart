import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';

class BoostInfoScreen extends StatelessWidget {
  const BoostInfoScreen({super.key});

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
          'Learn more about Boosts',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is a Boost?',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'We want to help you sell better and fast!\n\nBoost help increase the visibility of your listings on the marketplace by updation your listing time to the time when you buy the boost. As listing time is a significant component in our search and browse algorithms, boosted listings get ranked higher. After which, it will behave like a normal listing and be moved down as new listings are added to the marketplace.\n\nBy doing so, Boost can provide your listing with increased exposure.\n\nGet your listings noticed now with a Boost!',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              CachedNetworkImage(
                imageUrl:
                    'https://res.cloudinary.com/bechdeapp/image/upload/v1674460265/illustrations/boost-to-top-gif_yac6tr.gif',
                height: size.height * 0.5,
                width: size.width,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'How to buy a Boost?',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '1) Click \'Promote Listing\' on the listing you want to boost.\n2) Click \'Buy Now\' on  the \'Boost to Top\' package.\n3) Make payment and you are good to go!',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'How long does a Boost last?',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'A Boost is an instant effect that brings your listing to the top of the marketplace. After which, it will behave like a normal listing and be moved down as new listings are added.',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Does a Boost guarantee a sale?',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Boost provides your listing with more visibility. However, we cannot guarantee that a Boost will lead to a like, chat or offer. To make sure you get the most out of Boosts, use them on good-quality listings.',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
