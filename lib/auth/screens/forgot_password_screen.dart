import 'package:buy_sell_app/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password-screen';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _forgotformKey = GlobalKey<FormState>();
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();

  _validateEmail() async {
    if (_forgotformKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text)
          .then((value) {
        showSnackBar(
          context: context,
          content: 'Link to reset password sent on your email.',
          color: redColor,
        );
      }).then((value) {
        Get.back();
      }).catchError((onError) {
        showSnackBar(
          context: context,
          content: 'Something has gone wrong. Please try again.',
          color: redColor,
        );
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Forgot password',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Form(
        key: _forgotformKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                label: 'Email address',
                hint: 'Enter your email address',
                maxLength: 50,
                textInputAction: TextInputAction.go,
                autofocus: true,
                validator: (value) {
                  final bool isValid =
                      EmailValidator.validate(emailController.text);
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (value.isNotEmpty && isValid == false) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'We\'ll send you a link to reset your password on this email.',
                style: GoogleFonts.poppins(
                  color: lightBlackColor,
                  fontSize: 13,
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
                      text: 'Send',
                      icon: FontAwesomeIcons.arrowRight,
                      bgColor: blackColor,
                      borderColor: blackColor,
                      textIconColor: whiteColor,
                      onPressed: () {
                        _validateEmail();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
