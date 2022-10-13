import 'package:buy_sell_app/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Login with your Email',
          style: GoogleFonts.poppins(
            color: Colors.black,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextField(
                      controller: emailController,
                      label: 'Email address',
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 40,
                      textInputAction: TextInputAction.next,
                      isEnabled: isLoading ? false : true,
                      validator: (value) {
                        final bool isValid =
                            EmailValidator.validate(emailController.text);
                        if (value == null || value.isEmpty) {
                          showSnackBar(
                            context: context,
                            content: 'Please enter your email address',
                          );
                        }
                        if (value!.isNotEmpty && isValid == false) {
                          showSnackBar(
                            context: context,
                            content: 'Please enter a valid email address',
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
                            hint: 'Enter your password',
                            maxLength: 15,
                            textInputAction: TextInputAction.go,
                            isObscured: isObscured ? true : false,
                            isEnabled: isLoading ? false : true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                showSnackBar(
                                  context: context,
                                  content: 'Please enter your password',
                                );
                              } else if (value.length < 6) {
                                showSnackBar(
                                  context: context,
                                  content:
                                      'Password must be 6 to 15 characters long',
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
                                    FontAwesomeIcons.solidEyeSlash,
                                    size: 20,
                                  )
                                : const Icon(
                                    FontAwesomeIcons.solidEye,
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
                        Navigator.of(context).pushNamed(
                          ForgotPasswordScreen.routeName,
                        );
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
                    Navigator.of(context)
                        .pushReplacementNamed(EmailRegisterScreen.routeName);
                  },
                  child: Text(
                    'Don\'t have an account? Create one',
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
                        text: 'Login',
                        icon: FontAwesomeIcons.rightToBracket,
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
