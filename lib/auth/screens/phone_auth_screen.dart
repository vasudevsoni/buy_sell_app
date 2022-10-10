import 'package:buy_sell_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../../auth/services/phone_auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  static const routeName = '/phone-auth-screen';
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final countryCodeController = TextEditingController(text: '+91');
  final mobileNumberController = TextEditingController();

  @override
  void dispose() {
    countryCodeController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  final PhoneAuthService _service = PhoneAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Login with your Mobile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    controller: countryCodeController,
                    label: 'Country',
                    hint: '',
                    keyboardType: TextInputType.text,
                    maxLength: 5,
                    textInputAction: TextInputAction.next,
                    isEnabled: false,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: mobileNumberController,
                    label: 'Mobile number',
                    hint: 'Enter your mobile number',
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    textInputAction: TextInputAction.go,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'We\'ll send a verification code to this number.',
              style: GoogleFonts.poppins(
                color: lightBlackColor,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Send code',
              icon: FontAwesomeIcons.arrowRight,
              bgColor: blackColor,
              textIconColor: Colors.white,
              onPressed: () {
                if (mobileNumberController.text.length == 10) {
                  String number =
                      '${countryCodeController.text}${mobileNumberController.text}';

                  _service.signInWithPhone(context, number);
                } else {
                  showSnackBar(
                    context: context,
                    content: 'Please enter a valid mobile number',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
