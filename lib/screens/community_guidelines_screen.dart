import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../provider/providers.dart';
import '../services/admob_services.dart';
import '../widgets/custom_button_without_icon.dart';
import '/utils/utils.dart';

class CommunityGuidelinesScreen extends StatefulWidget {
  const CommunityGuidelinesScreen({
    super.key,
  });

  @override
  State<CommunityGuidelinesScreen> createState() =>
      _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
  late NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initNativeAd();
  }

  _initNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: AdmobServices.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
          if (mounted) {
            ad.dispose();
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: smallNativeAdStyle,
    );
    // Preload the ad
    await _nativeAd!.load();
  }

  @override
  void dispose() {
    if (_nativeAd != null && mounted) {
      _nativeAd!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProv = Provider.of<AppNavigationProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Community Guidelines',
          style: GoogleFonts.interTight(
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
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: whiteColor,
                  border: greyBorder,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Ionicons.flash_outline,
                              color: greenColor,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Participate in our survey',
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                                color: blackColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: AutoSizeText(
                            'Help us improve BechDe by filling this survey.',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.interTight(
                              fontWeight: FontWeight.w500,
                              color: blackColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustomButtonWithoutIcon(
                      text: 'Let\'s go',
                      onPressed: () => showSurveyPopUp(context),
                      borderColor: blueColor,
                      bgColor: blueColor,
                      textIconColor: whiteColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
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
                      Ionicons.happy_outline,
                      color: whiteColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Welcome to BechDe',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.interTight(
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
                'Our community guidelines are designed to ensure that every member of our community is treated with respect and fairness, and to help make your experience on our platform enjoyable and safe.\n\nWe ask that you review these guidelines and follow them to maintain a healthy and thriving community.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '1. Be honest -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Honesty is key to building trust and credibility within our community. When posting a listing, be truthful about the condition of the item or service you are selling, and provide accurate information about its features, price, and location. If the item or service has any flaws or defects, please disclose them in the listing description. This ensures that buyers can make informed decisions and helps to prevent disputes.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '2. Respect the law -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'All listings and transactions must be legal. Any illegal items or services are not allowed to be posted on the platform. Additionally, all users must abide by local, state, and federal laws, as well as our platform policies. This includes complying with laws related to intellectual property, counterfeit items, and prohibited items. Failure to comply with these laws may result in account suspension or termination.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '3. Treat others with respect -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'We expect all members of our community to treat each other with respect and professionalism. This means no name-calling, bullying, or harassment. Any behavior that violates this guideline will not be tolerated. If you encounter any behavior that makes you feel uncomfortable, please report it to us immediately.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '4. Keep it clean -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'We strive to maintain a family-friendly environment on our platform. We ask that all users keep their listings clean and appropriate for all audiences. Listings with explicit or offensive content will be removed. This includes listings with discriminatory language or hate speech.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '5. Communicate clearly -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Effective communication is key to a successful transaction on BechDe. When communicating with other members, be clear and concise about what you are selling or buying, and be responsive to messages. Miscommunication can lead to disputes, so it\'s important to be clear and direct in your communication.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '6. Use common sense -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'While we work hard to ensure the safety and security of our platform, it\'s up to each individual user to determine whether a listing or transaction is safe and appropriate. Use your common sense and trust your instincts. If something seems too good to be true, it probably is. If you have any doubts or concerns about a listing or transaction, please reach out to us for assistance.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '7. Chat responsibly -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'BechDe provides a chat feature to facilitate communication between buyers and sellers. We ask that users communicate responsibly and keep the conversation focused on the transaction at hand. Please do not share personal details such as your address, phone number, or email address. It\'s also important to remember not to make advance payments before receiving the item or service.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '8. Report violations -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'We rely on our community to help us maintain a safe and fair marketplace. If you encounter a listing or behavior that violates our guidelines or policies, please report it to us immediately. We take all reports seriously and will take appropriate action to address any issues. This may include removing the listing, suspending or terminating the user\'s account, or contacting law enforcement.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
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
                      Ionicons.shield_checkmark,
                      color: whiteColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Tips to Stay Safe',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.interTight(
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
                'The safety and security of our users is a top priority at BechDe. Here are some guidelines for staying safe when meeting with a buyer or seller in-person for a deal, and how to prevent fraud and scams:',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '1. Meet in a safe and public place -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'When meeting with a buyer or seller in-person, choose a safe and public location, such as a coffee shop, mall, or near a police station. Avoid meeting in secluded areas or places that are not well-lit.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '2. Bring a friend or family member -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Consider bringing a friend or family member with you to the meeting. This not only adds an extra layer of security, but it can also make the experience more enjoyable and less stressful.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '3. Inspect the item thoroughly -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Before completing the transaction, inspect the item thoroughly to ensure that it meets your expectations. If you\'re purchasing an electronic item, test it out to make sure it\'s in working order.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '4. Verify the seller\'s identity -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Make sure you\'re dealing with a legitimate seller by verifying their identity. This can be done by checking their profile on BechDe and by asking for a government-issued ID or other form of identification.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '5. Use secure payment methods -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Do not send advance payments. Only pay the seller after inspecting the product properly, and confirming the seller\'s identity.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                '6. Beware of scams -',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  color: blackColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Unfortunately, there are scammers who use online marketplaces to take advantage of unsuspecting buyers and sellers. Be wary of deals that seem too good to be true, and be cautious of unsolicited messages or offers.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: redColor,
                ),
                child: Text(
                  'If you encounter any suspicious activity or fraudulent behavior, please report it to us immediately. We take all reports seriously and will take appropriate action to address any issues. With these guidelines in mind, we hope that you can enjoy a safe and successful buying and selling experience on BechDe!',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w500,
                    color: whiteColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Our team is dedicated to ensuring that BechDe is a safe and welcoming platform for all users. We understand that maintaining a positive community requires ongoing effort, and we are committed to taking swift action to address any issues that may arise.\nIf you have any questions, concerns, or feedback about our guidelines or platform, please don\'t hesitate to reach out to us at support@bechdeapp.com.\nWe welcome your input and are always looking for ways to improve our platform. We thank you for choosing BechDe and look forward to working with you to create a thriving online marketplace.',
                textAlign: TextAlign.start,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: mainProv.adsRemoved
          ? null
          : SmallNativeAd(
              nativeAd: _nativeAd,
              isAdLoaded: _isAdLoaded,
            ),
    );
  }
}
