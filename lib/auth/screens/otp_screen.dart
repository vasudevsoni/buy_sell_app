// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import 'package:pinput/pinput.dart';

// import '/utils/utils.dart';
// import '/widgets/custom_button_without_icon.dart';
// import '/widgets/timer_button.dart';
// import '../services/phone_auth_service.dart';

// class OTPScreen extends StatefulWidget {
//   final String verificationId;
//   final String mobileNumber;
//   OTPScreen({
//     Key? key,
//     required this.mobileNumber,
//     required this.verificationId,
//   }) : super(key: key);

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final TextEditingController otpController = TextEditingController();
//   FirebaseAuth auth = FirebaseAuth.instance;
//   final PhoneAuthService _services = PhoneAuthService();
//   final focusNode = FocusNode();
//   int noOfResends = 0;
//   bool isResendButtonDisabled = true;

//   @override
//   void dispose() {
//     otpController.dispose();
//     focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final defaultPinTheme = PinTheme(
//       height: 60,
//       GoogleFonts.interTight: GoogleFonts.interTight(
//         fontSize: 22,
//         color: blackColor,
//         fontWeight: FontWeight.w800,
//       ),
//       decoration: BoxDecoration(
//         color: greyColor,
//         borderRadius: BorderRadius.circular(5),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         color: whiteColor,
//         borderRadius: BorderRadius.circular(5),
//         boxShadow: [
//           BoxShadow(
//             color: fadedColor,
//             offset: Offset(0, 2),
//             blurRadius: 5,
//             spreadRadius: -2,
//           )
//         ],
//       ),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         color: greyColor,
//       ),
//     );

//     resendOTP() async {
//       await _services.signInWithPhone(
//         context: context,
//         phoneNumber: widget.mobileNumber,
//         isResend: true,
//       );
//     }

//     Future<void> verifyOTP(
//       BuildContext context,
//       String verificationId,
//       String userOTP,
//     ) async {
//       try {
//         PhoneAuthCredential credential = PhoneAuthProvider.credential(
//           verificationId: verificationId,
//           smsCode: userOTP,
//         );
//         await auth.signInWithCredential(credential).then((value) {
//           _services.addUser(value.user);
//         }).catchError((err) {
//           showSnackBar(
//             content: 'Login failed. Please try again',
//             color: redColor,
//           );
//         });
//       } on FirebaseAuthException {
//         showSnackBar(
//           content: 'Invalid OTP. Please try again',
//           color: redColor,
//         );
//       }
//     }

//     return Scaffold(
      // backgroundColor: whiteColor,
//       backgroundColor: whiteColor,
//       appBar: AppBar(
//         elevation: 0.2,
//         backgroundColor: whiteColor,
//         iconTheme: IconThemeData(color: blackColor),
//         centerTitle: true,
//         title: Text(
//           'Verification code',
//           style: GoogleFonts.interTight(
//             fontWeight: FontWeight.w500,
//             color: blackColor,
//             fontSize: 15,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(15.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               child: Center(
//                 child: Text(
//                   'Enter the code sent to ${widget.mobileNumber}.',
//                   style: GoogleFonts.interTight(
//                     color: lightBlackColor,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Pinput(
//               length: 6,
//               autofocus: true,
//               controller: otpController,
//               focusNode: focusNode,
//               isCursorAnimationEnabled: true,
//               keyboardType: TextInputType.number,
//               pinAnimationType: PinAnimationType.scale,
//               defaultPinTheme: defaultPinTheme,
//               focusedPinTheme: focusedPinTheme,
//               submittedPinTheme: submittedPinTheme,
//               pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//               showCursor: false,
//               inputFormatters: <TextInputFormatter>[
//                 FilteringTextInputFormatter.digitsOnly
//               ],
//               hapticFeedbackType: HapticFeedbackType.lightImpact,
//               onCompleted: (value) {
//                 verifyOTP(
//                   context,
//                   widget.verificationId,
//                   value,
//                 );
//               },
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             TextButton(
//               onPressed: () => Get.back(),
//               child: Text(
//                 'Change mobile number',
//                 style: GoogleFonts.interTight(
//                   color: blueColor,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//             Spacer(),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               child: Text(
//                 'Didn\'t receive the code?',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.interTight(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             noOfResends < 5
//                 ? TimerButton(
//                     label: "Resend Code",
//                     timeOutInSeconds: 30,
//                     onPressed: () {
//                       resendOTP();
//                       setState(() {
//                         noOfResends++;
//                       });
//                     },
//                     disabledColor: greyColor,
//                     color: blueColor,
//                   )
//                 : CustomButtonWithoutIcon(
//                     text: 'OTP Limit Exceeded',
//                     onPressed: () {},
//                     isDisabled: true,
//                     borderColor: lightBlackColor,
//                     bgColor: lightBlackColor,
//                     textIconColor: whiteColor,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
