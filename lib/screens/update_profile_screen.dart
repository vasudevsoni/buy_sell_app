import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_text_field.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  bool isLoading = false;

  String uid = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

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
      // value['profileImage'] == null
      //     ? downloadUrl = ''
      //     : downloadUrl = value['profileImage'];
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validateForm() async {
      if (_formKey.currentState!.validate()) {
        if (nameController.text.isNotEmpty && dobController.text.isNotEmpty) {
          showDialog(
            context: context,
            barrierColor: Colors.black87,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Ready to update?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: greyColor,
                  ),
                  child: Text(
                    'Are you sure you want to update your details?',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                actionsPadding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                titlePadding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 15,
                  bottom: 10,
                ),
                contentPadding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 5,
                  top: 5,
                ),
                actions: [
                  CustomButtonWithoutIcon(
                    text: 'Confirm & Update',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Navigator.pop(context);
                      // await uploadImage(File(pickedImage!.path));
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
                      showSnackBar(
                        context: context,
                        content: 'Profile updated successfully',
                        color: blueColor,
                      );
                    },
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Go Back & Check',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    bgColor: Colors.white,
                    borderColor: blueColor,
                    textIconColor: blueColor,
                  ),
                ],
              );
            },
          );
        } else {
          showSnackBar(
            context: context,
            content: 'Please fill all the fields marked with *',
            color: redColor,
          );
        }
      } else {
        showSnackBar(
          context: context,
          content: 'Please fill all the fields marked with *',
          color: redColor,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Edit your profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blueColor,
                  child: Text(
                    'Profile Details',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    label: 'Name',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: bioController,
                    keyboardType: TextInputType.multiline,
                    label: 'Bio',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: dobController,
                    keyboardType: TextInputType.text,
                    label: 'Date of Birth',
                    hint: '',
                    maxLength: 80,
                    isReadOnly: true,
                    isEnabled: isLoading ? false : true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        helpText: 'SELECT DATE OF BIRTH',
                        locale: const Locale('en', 'IN'),
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 54750),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat.yMMMd().format(pickedDate);
                        setState(() {
                          dobController.text = formattedDate;
                        });
                      } else {
                        return;
                      }
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 244, 241, 241),
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 10,
          top: 10,
        ),
        child: isLoading
            ? CustomButton(
                text: 'Loading..',
                onPressed: () {},
                isDisabled: isLoading,
                icon: FontAwesomeIcons.spinner,
                bgColor: blackColor,
                borderColor: blackColor,
                textIconColor: Colors.white,
              )
            : CustomButton(
                text: 'Proceed',
                onPressed: validateForm,
                icon: Iconsax.arrow_circle_right4,
                bgColor: blueColor,
                borderColor: blueColor,
                textIconColor: Colors.white,
              ),
      ),
    );
  }
}
