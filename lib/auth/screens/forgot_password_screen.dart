import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/loading_button.dart';
import '../../widgets/text_field_label.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_text_field.dart';
import '/utils/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _forgotformKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _validateEmail() async {
    if (_forgotformKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text);
        showSnackBar(
          content: 'Link to reset password sent on your email',
          color: redColor,
        );
        Get.back();
      } on FirebaseAuthException {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
      }
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
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Forgot password',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w500,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TextFieldLabel(labelText: 'Email Address'),
              CustomTextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'johndoe@gmail.com',
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
                height: 10,
              ),
              Text(
                'We\'ll send you a link to reset your password on this email',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w400,
                  color: blackColor,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              isLoading
                  ? const LoadingButton(
                      bgColor: blueColor,
                    )
                  : CustomButton(
                      text: 'Send',
                      icon: Ionicons.arrow_forward,
                      bgColor: blueColor,
                      borderColor: blueColor,
                      textIconColor: whiteColor,
                      onPressed: () => _validateEmail(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
