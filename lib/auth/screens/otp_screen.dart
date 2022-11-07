import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/custom_button_without_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pinput/pinput.dart';

import '../../widgets/timer_button.dart';
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
  FirebaseAuth auth = FirebaseAuth.instance;
  final PhoneAuthService _services = PhoneAuthService();
  final focusNode = FocusNode();
  int noOfResends = 0;
  bool isResendButtonDisabled = true;

  @override
  void dispose() {
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        color: blackColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: fadedColor,
            offset: Offset(0, 2),
            blurRadius: 5,
            spreadRadius: -2,
          )
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: greyColor,
      ),
    );

    resendOTP() async {
      await _services.signInWithPhone(
        context: context,
        phoneNumber: widget.mobileNumber,
        isResend: true,
      );
    }

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
        await auth.signInWithCredential(credential).then((value) {
          _services.addUser(context, value.user);
        }).catchError((err) {
          showSnackBar(
            context: context,
            content: 'Login failed. Please try again.',
            color: redColor,
          );
        });
      } on FirebaseAuthException {
        showSnackBar(
          context: context,
          content: 'Invalid OTP. Please try again.',
          color: redColor,
        );
      }
    }

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Verification code',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Text(
                  'Enter the code sent to ${widget.mobileNumber}.',
                  style: GoogleFonts.poppins(
                    color: lightBlackColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Pinput(
              length: 6,
              autofocus: true,
              controller: otpController,
              focusNode: focusNode,
              isCursorAnimationEnabled: true,
              keyboardType: TextInputType.number,
              pinAnimationType: PinAnimationType.scale,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: false,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (value) {
                verifyOTP(
                  context,
                  widget.verificationId,
                  value,
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                'Didn\'t receive the code?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            noOfResends < 5
                ? TimerButton(
                    label: "Resend Code",
                    timeOutInSeconds: 30,
                    onPressed: () {
                      resendOTP();
                      setState(() {
                        noOfResends++;
                      });
                    },
                    disabledColor: greyColor,
                    color: blackColor,
                  )
                : CustomButtonWithoutIcon(
                    text: 'OTP Limit exceeded',
                    onPressed: () {},
                    isDisabled: true,
                    borderColor: lightBlackColor,
                    bgColor: lightBlackColor,
                    textIconColor: whiteColor,
                  ),
          ],
        ),
      ),
    );
  }
}
