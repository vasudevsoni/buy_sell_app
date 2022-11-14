import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '/utils/utils.dart';
import '../services/email_auth_service.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_text_field.dart';
import 'email_login_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final _registerformKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
        title: const Text(
          'Register with your email',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Form(
        key: _registerformKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    return 'Please enter your name';
                  }
                  if (value.length == 1) {
                    return 'Please enter a valid name';
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
                      hint: 'Create a password',
                      maxLength: 15,
                      textInputAction: TextInputAction.next,
                      isObscured: isObscured ? true : false,
                      isEnabled: isLoading ? false : true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
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
              const Spacer(),
              TextButton(
                onPressed: () => Get.off(
                  () => const EmailLoginScreen(),
                ),
                child: const AutoSizeText(
                  'Already have an account? Login',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
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
                      text: 'Create Account',
                      icon: FontAwesomeIcons.userPlus,
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
