import 'package:buy_sell_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/custom_text_field.dart';
import '../services/phone_auth_service.dart';

class OTPScreen extends StatefulWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;
  final String mobileNumber;
  const OTPScreen({
    Key? key,
    required this.mobileNumber,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final PhoneAuthService _service = PhoneAuthService();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Future<void> verifyOTP(
      BuildContext context,
      String verificationId,
      String userOTP,
    ) async {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: userOTP,
        );
        User? user = (await auth.signInWithCredential(credential)).user;

        if (user != null) {
          // ignore: use_build_context_synchronously
          _service.addUser(context, user);
        } else {
          showSnackBar(
            context: context,
            content: 'Login failed. Please try again.',
            color: redColor,
          );
        }
      } on FirebaseAuthException {
        showSnackBar(
          context: context,
          content: 'Invalid OTP. Please try again.',
          color: redColor,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Verification code',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            CustomTextField(
              controller: otpController,
              label: 'OTP',
              hint: 'Enter the OTP',
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 6,
              textInputAction: TextInputAction.go,
              onChanged: (val) {
                if (val.length == 6) {
                  verifyOTP(context, widget.verificationId, val.trim());
                }
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'We\'ve sent a code to ${widget.mobileNumber}. It may take a few moments to arrive.',
              style: GoogleFonts.poppins(
                color: lightBlackColor,
                fontSize: 13,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Change mobile number',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: blueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
