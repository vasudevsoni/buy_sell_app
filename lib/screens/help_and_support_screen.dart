import 'package:buy_sell_app/screens/community_guidelines_screen.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '/widgets/custom_list_tile_no_image.dart';
import '/utils/utils.dart';
import 'report_screen.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final FirebaseServices _services = FirebaseServices();
  late final PackageInfo packageInfo;
  String uid = '';
  String version = '';

  @override
  void initState() {
    super.initState();
    uid = _services.user!.uid;
    getDetails();
  }

  Future<void> getDetails() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  Future<void> openMail(email) async {
    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      showSnackBar(
        content: 'Something went wrong. Please try again',
        color: redColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Email dataDeleteEmail = Email(
      body:
          '{Do not delete this.\nHi, I would like to delete my data and account for BechDe.\nUserId - $uid}',
      subject: 'Delete BechDe Data',
      recipients: ['support@bechdeapp.com'],
      isHTML: false,
    );
    final Email contactUsEmail = Email(
      body:
          'Contact us regarding any issue you are facing. We will get back to you very soon.\nExplain in detail the problem you are facing.',
      recipients: ['support@bechdeapp.com'],
      isHTML: false,
    );
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Help and support',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                'Actions',
                style: GoogleFonts.sora(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: greyBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                children: [
                  CustomListTileNoImage(
                    text: 'Participate in our survey',
                    icon: Ionicons.flash_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => showSurveyPopUp(context),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Contact Us',
                    icon: Ionicons.mail_open_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => openMail(contactUsEmail),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Report a problem',
                    icon: Ionicons.bug_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => Get.to(
                      () => const ReportScreen(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: size.width,
              child: Text(
                'About',
                style: GoogleFonts.sora(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: greyBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                children: [
                  CustomListTileNoImage(
                    text: 'Community Guidelines',
                    icon: Ionicons.people_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => Get.to(
                      () => const CommunityGuidelinesScreen(),
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'FAQs',
                    icon: Ionicons.help_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://www.bechdeapp.com/faqs'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Terms of Service',
                    icon: Ionicons.book_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://www.bechdeapp.com/terms'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Privacy Policy',
                    icon: Ionicons.lock_closed_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://www.bechdeapp.com/privacy-policy'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Icons by Icons8',
                    icon: Ionicons.happy_outline,
                    trailingIcon: Ionicons.chevron_forward,
                    isEnabled: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://icons8.com/'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: fadedColor,
                    indent: 15,
                  ),
                  CustomListTileNoImage(
                    text: 'Version $version',
                    icon: Ionicons.phone_portrait_outline,
                    isEnabled: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: size.width,
              child: Text(
                'Data',
                style: GoogleFonts.sora(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: greyBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomListTileNoImage(
                text: 'Request Account Deletion',
                icon: Ionicons.trash_outline,
                trailingIcon: Ionicons.chevron_forward,
                isEnabled: true,
                onTap: () => openMail(dataDeleteEmail),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
