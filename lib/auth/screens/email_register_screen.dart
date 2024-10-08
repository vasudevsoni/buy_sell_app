import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/custom_button_without_icon.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/text_field_label.dart';
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
  final GlobalKey<FormState> _registerformKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final EmailAuthService _service = EmailAuthService();
  bool isLoading = false;
  bool isObscured = true;

  _validateEmail() async {
    if (_registerformKey.currentState!.validate() && mounted) {
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
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Register with your email',
          style: GoogleFonts.interTight(
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
              const TextFieldLabel(labelText: 'Name'),
              CustomTextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                hint: 'John Doe',
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
              const TextFieldLabel(labelText: 'Email address'),
              CustomTextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'johndoe@gmail.com',
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
              const Spacer(),
              const SizedBox(
                height: 5,
              ),
              isLoading
                  ? const LoadingButton(
                      bgColor: blueColor,
                    )
                  : CustomButton(
                      text: 'Create Account',
                      icon: Ionicons.person_add,
                      bgColor: blueColor,
                      borderColor: blueColor,
                      textIconColor: whiteColor,
                      onPressed: () => _validateEmail(),
                    ),
              CustomButtonWithoutIcon(
                text: 'Already have an account? Login',
                bgColor: whiteColor,
                borderColor: blueColor,
                textIconColor: blueColor,
                onPressed: () => Get.off(
                  () => const EmailLoginScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
