import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '/screens/main_screen.dart';
import '/utils/utils.dart';
import '/widgets/timer_button.dart';

class EmailVerificationScreen extends StatefulWidget {
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
    super.initState();
    isEmailVerified = user!.emailVerified;
  }

  Future<void> checkEmailVerified() async {
    await user!.reload();
    user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        isEmailVerified = user!.emailVerified;
      });
    }
    if (isEmailVerified) {
      timer!.cancel();
      showSnackBar(
        content: 'Email has been verified',
        color: blueColor,
      );
      Get.offAll(() => const MainScreen(selectedIndex: 3));
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();
      showSnackBar(
        content: 'Verification email sent successfully',
        color: blueColor,
      );
      startEmailVerificationTimer();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
          content: 'User not found. Please try again',
          color: redColor,
        );
      } else {
        showSnackBar(
          content: 'Unable to send verification email. Please try again',
          color: redColor,
        );
      }
    } on Exception catch (_) {
      showSnackBar(
        content: 'Something went wrong. Please try again',
        color: redColor,
      );
    }
  }

  // Start a timer to periodically check if the user's email has been verified
  void startEmailVerificationTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

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
          'Verify your email',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: const Icon(
                Ionicons.shield_checkmark,
                color: blueColor,
                size: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Click on the link you received on your registered email address to verify your email.',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: blackColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Text(
                  'Note - Check your spam folder if you cannot find the verification email.',
                  style: GoogleFonts.sora(
                    color: whiteColor,
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
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: TimerButton(
                label: "Resend Code",
                timeOutInSeconds: 30,
                onPressed: () => sendVerificationEmail(),
                disabledColor: greyColor,
                color: blueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
