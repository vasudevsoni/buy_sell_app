import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/utils/utils.dart';
import '/widgets/custom_text_field.dart';
import '/widgets/custom_button.dart';
import '/auth/services/phone_auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _mobileLoginFormKey = GlobalKey<FormState>();
  final countryCodeController = TextEditingController(text: '+91');
  final mobileNumberController = TextEditingController();
  bool isLoading = false;

  _validateMobile() async {
    setState(() {
      isLoading = true;
    });
    if (_mobileLoginFormKey.currentState!.validate()) {
      String number =
          '${countryCodeController.text}${mobileNumberController.text}';
      await _service.signInWithPhone(
        context: context,
        phoneNumber: number,
        isResend: false,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

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
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Login with your mobile',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Form(
        key: _mobileLoginFormKey,
        child: Padding(
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
                    child: TextFormField(
                      controller: mobileNumberController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      enabled: isLoading ? false : true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (value.length != 10) {
                          return 'Please enter a valid mobile number';
                        }
                        return null;
                      },
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: 'Enter your mobile number',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        counterText: '',
                        fillColor: greyColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: transparentColor,
                            width: 0,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: transparentColor,
                            width: 0,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: redColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: redColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: greyColor,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        floatingLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: lightBlackColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'We\'ll send a verification code to this number.',
                style: TextStyle(
                  color: lightBlackColor,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              isLoading
                  ? CustomButton(
                      text: 'Loading...',
                      icon: FontAwesomeIcons.spinner,
                      bgColor: greyColor,
                      borderColor: greyColor,
                      textIconColor: blackColor,
                      onPressed: () {},
                      isDisabled: isLoading,
                    )
                  : CustomButton(
                      text: 'Proceed',
                      icon: FontAwesomeIcons.arrowRight,
                      bgColor: blueColor,
                      borderColor: blueColor,
                      textIconColor: whiteColor,
                      onPressed: _validateMobile,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
