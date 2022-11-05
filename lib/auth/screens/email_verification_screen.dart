import 'dart:async';
import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/utils.dart';
import '../../widgets/timer_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  static const String routeName = '/email-verification-screen';
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    isEmailVerified = user!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        checkEmailVerified();
      });
    } else {
      showSnackBar(
        context: context,
        content: 'Email has been verified',
        color: redColor,
      );
    }
    super.initState();
  }

  Future checkEmailVerified() async {
    await user!.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      isEmailVerified = user!.emailVerified;
    });
    if (isEmailVerified) {
      timer?.cancel();
      showSnackBar(
        context: context,
        content: 'Email has been verified',
        color: blueColor,
      );
      Get.offAll(() => const MainScreen(
            selectedIndex: 3,
          ));
    }
  }

  Future sendVerificationEmail() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();
      showSnackBar(
        context: context,
        content: 'Verification email sent successfully.',
        color: redColor,
      );
    } on FirebaseAuthException catch (_) {
      showSnackBar(
        context: context,
        content: 'Unable to send verification email. Please try again.',
        color: redColor,
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Verify your email',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: const Icon(
                FontAwesomeIcons.envelopeCircleCheck,
                color: blueColor,
                size: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Click on the link you received on your registered email address to verify your email.',
                style: GoogleFonts.poppins(
                  color: blackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Text(
                  'Note - Check your spam folder if you cannot find the verification email.',
                  style: GoogleFonts.poppins(
                    color: blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Did not receive the mail yet?',
                style: GoogleFonts.poppins(
                  color: blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: TimerButton(
                label: "Resend Code",
                timeOutInSeconds: 30,
                onPressed: sendVerificationEmail,
                disabledColor: greyColor,
                color: blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
