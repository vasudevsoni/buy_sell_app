import 'package:buy_sell_app/screens/feedback_screen.dart';
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
import '/widgets/custom_list_tile_with_subtitle.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final FirebaseServices _services = FirebaseServices();
  late PackageInfo packageInfo;
  String uid = '';
  String version = '';

  @override
  void initState() {
    setState(() {
      uid = _services.user!.uid;
    });
    getDetails();
    super.initState();
  }

  getDetails() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  openMail(email) async {
    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    final Email dataDeleteEmail = Email(
      body:
          '**Do not delete this.\nHi, I would like to delete my data and account for BechDe.\nUserId - $uid **',
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
                'Actions',
                style: GoogleFonts.interTight(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Make a suggestion',
              subTitle:
                  'If you have some feedback, suggestions or improvements for our app, we would love to hear them',
              icon: Ionicons.cafe,
              textColor: blackColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => Get.to(
                () => const FeedbackScreen(),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Contact Us',
              subTitle: 'Contact us for any issues you are facing',
              icon: Ionicons.mail,
              textColor: blackColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => openMail(contactUsEmail),
            ),
            CustomListTileWithSubtitle(
              text: 'Report a problem',
              subTitle: 'If something is not right, please report it here',
              icon: Ionicons.bug,
              textColor: redColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => Get.to(
                () => const ReportScreen(),
              ),
            ),
            const Divider(
              height: 0,
              indent: 15,
              color: lightBlackColor,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: size.width,
              child: Text(
                'About',
                style: GoogleFonts.interTight(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CustomListTileNoImage(
              text: 'FAQs',
              icon: Ionicons.help_circle,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => launchUrl(
                Uri.parse('https://www.bechdeapp.com/faqs'),
              ),
            ),
            CustomListTileNoImage(
              text: 'Terms of Service',
              icon: Ionicons.book,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => launchUrl(
                Uri.parse('https://www.bechdeapp.com/terms'),
              ),
            ),
            CustomListTileNoImage(
              text: 'Privacy Policy',
              icon: Ionicons.lock_closed,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => launchUrl(
                Uri.parse('https://www.bechdeapp.com/privacy-policy'),
              ),
            ),
            CustomListTileNoImage(
              text: 'Icons by Icons8',
              icon: Ionicons.balloon,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => launchUrl(
                Uri.parse('https://icons8.com/'),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Version',
              subTitle: version,
              icon: Ionicons.phone_portrait,
              isEnabled: false,
              onTap: () {},
            ),
            const Divider(
              height: 0,
              indent: 15,
              color: lightBlackColor,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: size.width,
              child: Text(
                'Data',
                style: GoogleFonts.interTight(
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Request Account Deletion',
              subTitle:
                  'If you would like to delete your account and data, leave us a request here',
              icon: Ionicons.trash,
              textColor: redColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => openMail(dataDeleteEmail),
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
