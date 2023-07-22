import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/utils.dart';
import '../widgets/custom_button.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

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
          'How to use BechDe?',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Ionicons.book_outline,
                      color: whiteColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Learn to use the app',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w800,
                        color: whiteColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'BechDe is designed to provide a seamless and user-friendly experience, connecting buyers and sellers in a safe and efficient marketplace.\nWhether you\'re looking to buy or sell, BechDe offers a convenient platform to discover great deals and connect with like-minded individuals.',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'How to list a product?',
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
              CustomButton(
                text: 'Watch Tutorial on YouTube',
                onPressed: () => launchUrl(
                  Uri.parse(
                      'https://youtube.com/shorts/2GOwAxxo_Jg?feature=share'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: Ionicons.logo_youtube,
                borderColor: redColor,
                bgColor: redColor,
                textIconColor: whiteColor,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '1) Click the + button on the bottom of the screen.\n2) Select a Category for the product.\n3) Select a Sub-Category.\n4) Fill all the required listing details.\n5) Click on Proceed to submit the listing.',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'How to edit a product?',
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
              CustomButton(
                text: 'Watch Tutorial on YouTube',
                onPressed: () => launchUrl(
                  Uri.parse(
                      'https://youtube.com/shorts/f_fRKuwNG-o?feature=share'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: Ionicons.logo_youtube,
                borderColor: redColor,
                bgColor: redColor,
                textIconColor: whiteColor,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '1) Go to the Account Section.\n2) Click on My Listings.\n3) Tap the three dots on the product you want to edit.\n4) Click on Edit Product.\n5) Edit the details that you want to change.\n6) Click on Proceed to submit the changes.',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'How to contact a seller?',
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
              CustomButton(
                text: 'Watch Tutorial on YouTube',
                onPressed: () => launchUrl(
                  Uri.parse(
                      'https://youtube.com/shorts/UxzD3rOeHRo?feature=share'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: Ionicons.logo_youtube,
                borderColor: redColor,
                bgColor: redColor,
                textIconColor: whiteColor,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '1) Open a product listing.\n2) Click on Chat now or Make an offer.\n3) You can now chat with the seller and talk about your deal.',
                textAlign: TextAlign.start,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'How to report a user?',
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
              CustomButton(
                text: 'Watch Tutorial on YouTube',
                onPressed: () => launchUrl(
                  Uri.parse(
                      'https://youtube.com/shorts/Gaz68zPg9uE?feature=share'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: Ionicons.logo_youtube,
                borderColor: redColor,
                bgColor: redColor,
                textIconColor: whiteColor,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '1) Go to the user profile page from a chat screen or from a listing screen by tapping on the user\'s name.\n2) Click on the three dots on the top right corner.\n3) Click on Report user.\n4) Enter details about why you are reporting the user.\n5) Click on Report.\nWe will reveiw the report and take neccessary actions if required.',
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
