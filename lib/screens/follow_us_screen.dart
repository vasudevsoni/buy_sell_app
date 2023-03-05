import 'package:buy_sell_app/widgets/custom_list_tile_no_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '/utils/utils.dart';

class FollowUsScreen extends StatelessWidget {
  const FollowUsScreen({super.key});

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
          'Follow Us',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                'Our Social Media',
                style: GoogleFonts.interTight(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CustomListTileNoImage(
              text: 'Facebook',
              icon: Ionicons.logo_facebook,
              trailingIcon: Ionicons.chevron_forward,
              onTap: () => launchUrl(
                Uri.parse(
                    'https://www.facebook.com/profile.php?id=100088872034817'),
              ),
              isEnabled: true,
            ),
            CustomListTileNoImage(
              text: 'Instagram',
              icon: Ionicons.logo_instagram,
              trailingIcon: Ionicons.chevron_forward,
              onTap: () => launchUrl(
                Uri.parse('https://www.instagram.com/bechdeofficial/'),
              ),
              isEnabled: true,
            ),
            CustomListTileNoImage(
              text: 'Twitter',
              icon: Ionicons.logo_twitter,
              trailingIcon: Ionicons.chevron_forward,
              onTap: () => launchUrl(
                Uri.parse('https://twitter.com/BechDeOfficial'),
              ),
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
