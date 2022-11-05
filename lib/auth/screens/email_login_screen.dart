import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../services/email_auth_service.dart';
import '../../auth/screens/email_register_screen.dart';
import '../../auth/screens/forgot_password_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  static const String routeName = '/email-login-screen';
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _loginformKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isObscured = true;
  bool isLoading = false;

  final EmailAuthService _service = EmailAuthService();

  _validateEmail() async {
    if (_loginformKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _service.loginUser(
        context: context,
        email: emailController.text,
        password: passwordController.text,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
          'Login with your Email',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Form(
        key: _loginformKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height -
                56 -
                MediaQuery.of(context).viewPadding.top,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextField(
                      controller: emailController,
                      label: 'Email address',
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 100,
                      textInputAction: TextInputAction.next,
                      isEnabled: isLoading ? false : true,
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
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: CustomTextField(
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            label: 'Password',
                            hint: 'Enter your password',
                            maxLength: 15,
                            textInputAction: TextInputAction.go,
                            isObscured: isObscured ? true : false,
                            isEnabled: isLoading ? false : true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Password must be 6 to 15 characters long';
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
                                    FontAwesomeIcons.eyeSlash,
                                    size: 20,
                                  )
                                : const Icon(
                                    FontAwesomeIcons.eye,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(ForgotPasswordScreen.routeName);
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Get.offNamed(
                      EmailRegisterScreen.routeName,
                    );
                  },
                  child: AutoSizeText(
                    'Don\'t have an account? Create one',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: blueColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                isLoading
                    ? CustomButton(
                        text: 'Loading..',
                        icon: FontAwesomeIcons.spinner,
                        bgColor: greyColor,
                        borderColor: greyColor,
                        textIconColor: blackColor,
                        onPressed: () {},
                        isDisabled: isLoading,
                      )
                    : CustomButton(
                        text: 'Login',
                        icon: FontAwesomeIcons.rightToBracket,
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
      ),
    );
  }
}
