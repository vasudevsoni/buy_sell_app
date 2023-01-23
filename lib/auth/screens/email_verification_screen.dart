import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
    isEmailVerified = user!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        checkEmailVerified();
      });
      return;
    }
    showSnackBar(
      content: 'Email has been verified',
      color: redColor,
    );
    super.initState();
  }

  Future checkEmailVerified() async {
    await user!.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      isEmailVerified = user!.emailVerified;
    });
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
      user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();
      showSnackBar(
        content: 'Verification email sent successfully',
        color: blueColor,
      );
    } on FirebaseAuthException catch (_) {
      showSnackBar(
        content: 'Unable to send verification email. Please try again',
        color: redColor,
      );
    }
  }

  @override
  void dispose() {
    timer!.cancel();
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
        title: const Text(
          'Verify your email',
          style: TextStyle(
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
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Click on the link you received on your registered email address to verify your email.',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: lightBlackColor,
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
                  color: greyColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: const Text(
                  'Note - Check your spam folder if you cannot find the verification email.',
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Did not receive the mail yet?',
                style: TextStyle(
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
