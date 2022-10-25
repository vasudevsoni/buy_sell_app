import 'package:buy_sell_app/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

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
          content: 'Link to reset password sent on your email',
          color: redColor,
        );
      }).then((value) {
        Navigator.pop(context);
      }).catchError((onError) {
        showSnackBar(
          context: context,
          content: 'Some error occurred. Please try again',
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
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Forgot password',
          style: GoogleFonts.poppins(
            color: Colors.black,
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
                    showSnackBar(
                      context: context,
                      content: 'Enter email address',
                      color: redColor,
                    );
                  }
                  if (value!.isNotEmpty && isValid == false) {
                    showSnackBar(
                      context: context,
                      content: 'Please enter a valid email address',
                      color: redColor,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'We\'ll send a link to reset your password on this email.',
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
                      bgColor: blackColor,
                      borderColor: blackColor,
                      textIconColor: Colors.white,
                      onPressed: () {},
                      isDisabled: isLoading,
                    )
                  : CustomButton(
                      text: 'Send',
                      icon: Iconsax.arrow_circle_right4,
                      bgColor: blackColor,
                      borderColor: blackColor,
                      textIconColor: Colors.white,
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
