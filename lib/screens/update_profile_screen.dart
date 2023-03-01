import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController instaController = TextEditingController();
  final TextEditingController fbController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
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
      value['instagramLink'] == null
          ? instaController.text = ''
          : instaController.text = value['instagramLink'];
      value['facebookLink'] == null
          ? fbController.text = ''
          : fbController.text = value['facebookLink'];
      value['websiteLink'] == null
          ? linkController.text = ''
          : linkController.text = value['websiteLink'];
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      if (instaController.text.isNotEmpty &&
          !instaController.text.startsWith('https://instagram.com/') &&
          !instaController.text.startsWith('https://www.instagram.com/') &&
          !instaController.text.startsWith('http://instagram.com/') &&
          !instaController.text.startsWith('http://www.instagram.com/')) {
        showSnackBar(
          content: 'Please enter a valid instagram profile link',
          color: redColor,
        );
        return;
      }
      if (fbController.text.isNotEmpty &&
          !fbController.text.startsWith('https://facebook.com/') &&
          !fbController.text.startsWith('https://www.facebook.com/') &&
          !fbController.text.startsWith('http://facebook.com/') &&
          !fbController.text.startsWith('http://www.facebook.com/') &&
          !fbController.text.startsWith('http://fb.com/') &&
          !fbController.text.startsWith('http://www.fb.com/')) {
        showSnackBar(
          content: 'Please enter a valid facebook profile link',
          color: redColor,
        );
        return;
      }
      if (linkController.text.isNotEmpty &&
          !linkController.text.startsWith('https://') &&
          !linkController.text.startsWith('http://') &&
          !linkController.text.startsWith('https://www') &&
          !linkController.text.startsWith('http://www')) {
        showSnackBar(
          content: 'Please enter a valid website/app link',
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
                  Center(
                    child: Text(
                      'Ready to update?',
                      style: GoogleFonts.interTight(
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
                    child: Text(
                      'Are you sure you want to update your details?',
                      style: GoogleFonts.interTight(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButtonWithoutIcon(
                          text: 'Cancel',
                          onPressed: () => Get.back(),
                          bgColor: whiteColor,
                          borderColor: greyColor,
                          textIconColor: blackColor,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: CustomButton(
                          text: 'Update',
                          icon: Ionicons.checkmark,
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
                              'instagramLink': instaController.text.isEmpty
                                  ? null
                                  : instaController.text,
                              'facebookLink': fbController.text.isEmpty
                                  ? null
                                  : fbController.text,
                              'websiteLink': linkController.text.isEmpty
                                  ? null
                                  : linkController.text,
                            });
                            setState(() {
                              isLoading = false;
                            });
                            Get.offAll(
                                () => const MainScreen(selectedIndex: 3));
                          },
                          bgColor: blueColor,
                          borderColor: blueColor,
                          textIconColor: whiteColor,
                        ),
                      ),
                    ],
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Edit your profile',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: TextFieldLabel(labelText: 'Instagram Link (Optional)'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  controller: instaController,
                  keyboardType: TextInputType.text,
                  hint: 'https://www.instagram.com/your_username/',
                  maxLength: 100,
                  maxLines: 1,
                  isEnabled: isLoading ? false : true,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFieldLabel(labelText: 'Facebook Link (Optional)'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  controller: fbController,
                  keyboardType: TextInputType.text,
                  hint:
                      'https://www.facebook.com/profile.php?id=100072729246997',
                  maxLength: 100,
                  maxLines: 1,
                  isEnabled: isLoading ? false : true,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFieldLabel(labelText: 'Website/App Link (Optional)'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  controller: linkController,
                  keyboardType: TextInputType.text,
                  hint: 'https://www.yourwebsite.com/',
                  maxLength: 100,
                  maxLines: 1,
                  isEnabled: isLoading ? false : true,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 15,
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
            ? const LoadingButton(
                bgColor: blueColor,
              )
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
