import 'dart:io';

import 'package:buy_sell_app/utils/utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firebase_services.dart';

class UpdateProfileImageScreen extends StatefulWidget {
  static const String routeName = '/update-profile-image-screen';
  const UpdateProfileImageScreen({super.key});

  @override
  State<UpdateProfileImageScreen> createState() =>
      _UpdateProfileImageScreenState();
}

class _UpdateProfileImageScreenState extends State<UpdateProfileImageScreen> {
  final FirebaseServices services = FirebaseServices();
  var uuid = const Uuid();
  String profileImage = '';
  XFile? pickedImage;
  String? downloadUrl;
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      getUserProfileImage();
    });
    super.initState();
  }

  getUserProfileImage() async {
    await services.getCurrentUserData().then((value) {
      if (mounted) {
        setState(() {
          if (value['profileImage'] == null) {
            profileImage = '';
          } else {
            profileImage = value['profileImage'];
          }
        });
      }
    });
  }

  uploadImage(File image) async {
    setState(() {
      isLoading = true;
    });
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profileImages/${services.user!.uid}/${uuid.v1()}');
    UploadTask uploadTask = storageReference.putFile(image);
    downloadUrl = await (await uploadTask).ref.getDownloadURL();
    services.users.doc(services.user!.uid).update({
      'profileImage': downloadUrl,
    });
    showSnackBar(
      context: context,
      content: 'Profile image updated',
      color: blueColor,
    );
    setState(() {
      isLoading = false;
      Navigator.pop(context);
    });
  }

  choosePhoto() async {
    final ImagePicker picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      pickedImage = picked;
    });
  }

  takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    setState(() {
      pickedImage = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            'Update profile image',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            profileImage == ''
                ? Container(
                    height: MediaQuery.of(context).size.width * 0.3,
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: blueColor,
                    ),
                    child: const Icon(
                      Iconsax.security_user4,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : pickedImage == null
                    ? SizedBox(
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: profileImage,
                            fit: BoxFit.cover,
                            placeholder: (context, event) {
                              return const Center(
                                child: SpinKitFadingCube(
                                  color: greyColor,
                                  size: 20,
                                  duration: Duration(milliseconds: 1000),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomButton(
                text: 'Take Photo',
                onPressed: takePhoto,
                icon: Iconsax.camera4,
                bgColor: blackColor,
                isDisabled: isLoading,
                borderColor: blackColor,
                textIconColor: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomButton(
                text: 'Choose Photo',
                onPressed: choosePhoto,
                icon: Iconsax.gallery4,
                bgColor: Colors.white,
                isDisabled: isLoading,
                borderColor: blackColor,
                textIconColor: blackColor,
              ),
            ),
          ],
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
                  text: 'Save',
                  onPressed: () {
                    uploadImage(File(pickedImage!.path));
                  },
                  icon: Iconsax.tick_circle4,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: Colors.white,
                ),
        ),
      ),
    );
  }
}
