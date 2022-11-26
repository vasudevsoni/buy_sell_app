import 'package:buy_sell_app/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/text_field_label.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_text_field.dart';
import '../services/email_auth_service.dart';
import '/auth/screens/email_register_screen.dart';
import '/auth/screens/forgot_password_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final EmailAuthService _service = EmailAuthService();
  bool isObscured = true;
  bool isLoading = false;

  _validateEmail() async {
    if (_loginformKey.currentState!.validate() && mounted) {
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Login with your email',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Form(
        key: _loginformKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TextFieldLabel(labelText: 'Email address'),
              CustomTextField(
                controller: emailController,
                hint: 'johndoe@gmail.com',
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
              const TextFieldLabel(labelText: 'Password'),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      hint: 'doejohn\$2325',
                      maxLength: 15,
                      textInputAction: TextInputAction.go,
                      isObscured: isObscured ? true : false,
                      isEnabled: isLoading ? false : true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be 6 to 15 characters long';
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () => setState(() {
                        isObscured = !isObscured;
                      }),
                      icon: isObscured
                          ? const Icon(
                              Ionicons.eye_off_outline,
                              size: 30,
                            )
                          : const Icon(
                              Ionicons.eye_outline,
                              size: 30,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.to(
                      () => const ForgotPasswordScreen(),
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: blueColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.off(
                  () => const EmailRegisterScreen(),
                ),
                child: const AutoSizeText(
                  'Don\'t have an account? Create one',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: blueColor,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              isLoading
                  ? const LoadingButton()
                  : CustomButton(
                      text: 'Login',
                      icon: Ionicons.log_in,
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
