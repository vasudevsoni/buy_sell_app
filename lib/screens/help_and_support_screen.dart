import 'package:buy_sell_app/screens/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'web_view/faqs.dart';
import 'web_view/privacy_policy_screen.dart';
import 'web_view/terms_of_service.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Help and support',
          style: TextStyle(
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
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: const Text(
                'Actions',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Give Feedback',
              subTitle:
                  'If you have some feedback, recommendations or improvements for us, we would love to hear them',
              icon: Ionicons.cafe,
              textColor: blackColor,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => Get.to(
                () => const FeedbackScreen(),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Report a Problem',
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
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'About',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Frequently Asked Questions',
              subTitle: 'Read our FAQ\'s for more details',
              icon: Ionicons.help_circle,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => Get.to(
                () => const FAQs(),
                transition: Transition.downToUp,
              ),
            ),
            CustomListTileNoImage(
              text: 'Terms of Service',
              icon: Ionicons.book,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => Get.to(
                () => const TermsOfService(),
                transition: Transition.downToUp,
              ),
            ),
            CustomListTileNoImage(
              text: 'Privacy Policy',
              icon: Ionicons.lock_closed,
              trailingIcon: Ionicons.chevron_forward,
              isEnabled: true,
              onTap: () => Get.to(
                () => const PrivacyPolicy(),
                transition: Transition.downToUp,
              ),
            ),
            CustomListTileWithSubtitle(
              text: 'Version',
              subTitle: '0.0.4',
              icon: Ionicons.phone_portrait,
              isEnabled: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
