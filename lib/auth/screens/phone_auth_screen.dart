// import 'package:buy_sell_app/widgets/text_field_label.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../../widgets/loading_button.dart';
// import '/utils/utils.dart';
// import '/widgets/custom_text_field.dart';
// import '/widgets/custom_button.dart';
// import '/auth/services/phone_auth_service.dart';

// class PhoneAuthScreen extends StatefulWidget {
//   PhoneAuthScreen({Key? key}) : super(key: key);

//   @override
//   State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
// }

// class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
//   final _mobileLoginFormKey = GlobalKey<FormState>();
//   final countryCodeController = TextEditingController(text: '+91');
//   final mobileNumberController = TextEditingController();
//   bool isLoading = false;

//   _validateMobile() async {
//     setState(() {
//       isLoading = true;
//     });
//     if (_mobileLoginFormKey.currentState!.validate()) {
//       String number =
//           '${countryCodeController.text}${mobileNumberController.text}';
//       await _service.signInWithPhone(
//         context: context,
//         phoneNumber: number,
//         isResend: false,
//       );
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     countryCodeController.dispose();
//     mobileNumberController.dispose();
//     super.dispose();
//   }

//   final PhoneAuthService _service = PhoneAuthService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      // backgroundColor: whiteColor,
//       backgroundColor: whiteColor,
//       appBar: AppBar(
//         elevation: 0.2,
//         backgroundColor: whiteColor,
//         iconTheme: IconThemeData(color: blackColor),
//         centerTitle: true,
//         title: Text(
//           'Login with your mobile',
//           style: GoogleFonts.interTight(
//             fontWeight: FontWeight.w500,
//             color: blackColor,
//             fontSize: 15,
//           ),
//         ),
//       ),
//       body: Form(
//         key: _mobileLoginFormKey,
//         child: Padding(
//           padding: EdgeInsets.all(15.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFieldLabel(labelText: 'Mobile Number'),
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 1,
//                     child: CustomTextField(
//                       controller: countryCodeController,
//                       hint: '',
//                       keyboardType: TextInputType.text,
//                       maxLength: 5,
//                       textInputAction: TextInputAction.next,
//                       isEnabled: false,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Expanded(
//                     flex: 3,
//                     child: TextFormField(
//                       controller: mobileNumberController,
//                       textInputAction: TextInputAction.done,
//                       keyboardType: TextInputType.number,
//                       maxLength: 10,
//                       enabled: isLoading ? false : true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your mobile number';
//                         }
//                         if (value.length != 10) {
//                           return 'Please enter a valid mobile number';
//                         }
//                         return null;
//                       },
//                       inputFormatters: <TextInputFormatter>[
//                         FilteringTextInputFormatter.digitsOnly
//                       ],
//                       style: GoogleFonts.interTight(
//                         fontWeight: FontWeight.w600,
//                         color: blackColor,
//                         fontSize: 16,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: '9876543210',
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 10,
//                         ),
//                         counterText: '',
//                         fillColor: greyColor,
//                         filled: true,
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: transparentColor,
//                             width: 0,
//                             strokeAlign: StrokeAlign.inside,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: transparentColor,
//                             width: 0,
//                             strokeAlign: StrokeAlign.inside,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: redColor,
//                             width: 1.5,
//                             strokeAlign: StrokeAlign.inside,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         errorStyle: GoogleFonts.interTight(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: redColor,
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: blueColor,
//                             width: 1.5,
//                             strokeAlign: StrokeAlign.inside,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         focusedErrorBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: blueColor,
//                             width: 1.5,
//                             strokeAlign: StrokeAlign.inside,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.never,
//                         hintStyle: GoogleFonts.interTight(
//                           fontSize: 16,
//                           fontWeight: FontWeight.normal,
//                           color: fadedColor,
//                         ),
//                         labelStyle: GoogleFonts.interTight(
//                           fontWeight: FontWeight.normal,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 'We\'ll send a verification code to this number.',
//                 style: GoogleFonts.interTight(
//                   color: lightBlackColor,
//                   fontSize: 15,
//                 ),
//               ),
//               Spacer(),
//               isLoading
//                   ? LoadingButton()
//                   : CustomButton(
//                       text: 'Proceed',
//                       icon: MdiIcons.arrowRight,
//                       bgColor: blueColor,
//                       borderColor: blueColor,
//                       textIconColor: whiteColor,
//                       onPressed: _validateMobile,
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
