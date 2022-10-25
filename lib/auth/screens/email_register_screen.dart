import 'package:buy_sell_app/auth/services/email_auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'email_login_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  static const String routeName = '/email-register-screen';
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final _registerformKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final EmailAuthService _service = EmailAuthService();
  bool isLoading = false;

  _validateEmail() async {
    if (_registerformKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _service.registerUser(
        context: context,
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isObscured = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
          'Register with your Email',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Form(
        key: _registerformKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height -
                56 -
                MediaQuery.of(context).viewPadding.top,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  label: 'Name',
                  hint: 'Enter your Name',
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  isEnabled: isLoading ? false : true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      showSnackBar(
                        context: context,
                        content: 'Please enter your name',
                        color: redColor,
                      );
                    }
                    if (value!.length == 1) {
                      showSnackBar(
                        context: context,
                        content: 'Please enter a valid name',
                        color: redColor,
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email address',
                  hint: 'Enter your Email address',
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  isEnabled: isLoading ? false : true,
                  validator: (value) {
                    final bool isValid =
                        EmailValidator.validate(emailController.text);
                    if (value == null || value.isEmpty) {
                      showSnackBar(
                        context: context,
                        content: 'Please enter your email address',
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
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: CustomTextField(
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        label: 'Password',
                        hint: 'Create a password',
                        maxLength: 15,
                        textInputAction: TextInputAction.next,
                        isObscured: isObscured ? true : false,
                        isEnabled: isLoading ? false : true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            showSnackBar(
                              context: context,
                              content: 'Please enter a password',
                              color: redColor,
                            );
                          } else if (value.length < 6) {
                            showSnackBar(
                              context: context,
                              content:
                                  'Password must be 6 to 15 characters long',
                              color: redColor,
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                        icon: isObscured
                            ? const Icon(
                                Iconsax.eye_slash4,
                                size: 20,
                              )
                            : const Icon(
                                Iconsax.eye,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(EmailLoginScreen.routeName);
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: blueColor,
                    ),
                  ),
                ),
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
                        text: 'Create account',
                        icon: Iconsax.tick_circle4,
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
      ),
    );
  }
}
