import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/utils.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({
    super.key,
  });

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
          'Community Guidelines',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to BechDe',
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
                'A community-driven platform where you can buy and sell goods and services near your locality.\n\nOur community guidelines are designed to ensure that every member of our community is treated with respect and fairness, and to help make your experience on our platform enjoyable and safe.\n\nWe ask that you review these guidelines and follow them to maintain a healthy and thriving community.',
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
                '7. Chat Responsibly -',
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
    );
  }
}
