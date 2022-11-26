import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

import '../widgets/loading_button.dart';
import '../widgets/text_field_label.dart';
import '/utils/utils.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  bool isLoading = false;
  String uid = '';

  @override
  void initState() {
    _services.getCurrentUserData().then((value) {
      uid = value['uid'];
      value['name'] == null
          ? nameController.text = ''
          : nameController.text = value['name'];
      value['bio'] == null
          ? bioController.text = ''
          : bioController.text = value['bio'];
      value['dob'] == null
          ? dobController.text == ''
          : dobController.text = value['dob'];
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    validateForm() async {
      if (!_formKey.currentState!.validate()) {
        showSnackBar(
          content: 'Please fill all the required fields',
          color: redColor,
        );
        return;
      }
      if (nameController.text.isEmpty) {
        showSnackBar(
          content: 'Please fill all the required fields',
          color: redColor,
        );
        return;
      }
      showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        backgroundColor: transparentColor,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: whiteColor,
              ),
              padding: const EdgeInsets.only(
                left: 15,
                top: 5,
                right: 15,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 80.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: fadedColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                    child: Text(
                      'Ready to update?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: greyColor,
                    ),
                    child: const Text(
                      'Are you sure you want to update your details?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Confirm & Update',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Get.back();
                      await _services.updateUserDetails(uid, {
                        'name': nameController.text,
                        'bio': bioController.text.isEmpty
                            ? null
                            : bioController.text,
                        'dob': dobController.text.isEmpty
                            ? null
                            : dobController.text,
                      });
                      setState(() {
                        isLoading = false;
                      });
                      Get.offAll(() => const MainScreen(selectedIndex: 3));
                    },
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Go Back & Check',
                    onPressed: () => Get.back(),
                    bgColor: whiteColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Edit your profile',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: blackColor,
                child: const Text(
                  'Profile Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFieldLabel(labelText: 'Name'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  hint: 'Enter you name',
                  maxLength: 80,
                  isEnabled: isLoading ? false : true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    setState(() {});
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFieldLabel(labelText: 'Bio (Optional)'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  controller: bioController,
                  keyboardType: TextInputType.multiline,
                  hint: 'Enter a short bio about yourself',
                  maxLength: 200,
                  maxLines: 3,
                  showCounterText: true,
                  isEnabled: isLoading ? false : true,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFieldLabel(labelText: 'Date of Birth (Optional)'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  controller: dobController,
                  keyboardType: TextInputType.text,
                  hint: '',
                  maxLength: 20,
                  isReadOnly: true,
                  isEnabled: isLoading ? false : true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      helpText: 'SELECT DATE OF BIRTH',
                      locale: const Locale('en', 'IN'),
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 54750),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate == null) {
                      return;
                    }
                    final String formattedDate =
                        DateFormat.yMMMd().format(pickedDate);
                    setState(() {
                      dobController.text = formattedDate;
                    });
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: greyColor,
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 10,
          top: 10,
        ),
        child: isLoading
            ? const LoadingButton()
            : CustomButton(
                text: 'Proceed',
                onPressed: validateForm,
                icon: Ionicons.arrow_forward,
                bgColor: blueColor,
                borderColor: blueColor,
                textIconColor: whiteColor,
              ),
      ),
    );
  }
}
