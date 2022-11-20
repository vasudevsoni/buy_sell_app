import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:image_picker/image_picker.dart';

import '../widgets/custom_button_without_icon.dart';
import '../widgets/loading_button.dart';
import '/widgets/custom_button.dart';
import '/utils/utils.dart';
import '/services/firebase_services.dart';

class UpdateProfileImageScreen extends StatefulWidget {
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
  String downloadUrl = '';
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
      if (!mounted) {
        return;
      }
      setState(() {
        if (value['profileImage'] != null) {
          profileImage = value['profileImage'];
          return;
        }
        profileImage = '';
      });
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
    setState(() {
      isLoading = false;
    });
  }

  choosePhoto() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      pickedImage = picked;
    });
  }

  takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.front,
    );
    setState(() {
      pickedImage = picked;
    });
  }

  void requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      takePhoto();
    } else if (status.isDenied) {
      if (await Permission.camera.request().isGranted) {
        takePhoto();
      } else {
        showSnackBar(
          content: 'Camera permission is required to take picture',
          color: redColor,
        );
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      showSnackBar(
        content: 'Permission is disabled. Please change from phone settings',
        color: redColor,
      );
      openAppSettings();
    }
  }

  void requestGalleryPermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      choosePhoto();
    } else if (status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        choosePhoto();
      } else {
        showSnackBar(
          content: 'Storage permission is required to upload picture',
          color: redColor,
        );
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      showSnackBar(
        content: 'Permission is disabled. Please change from phone settings',
        color: redColor,
      );
      openAppSettings();
    }
  }

  showConfirmationDialog() {
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
                    'Are you sure you want to update your profile image?',
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
                    await uploadImage(File(pickedImage!.path));
                    Get.back();
                    Get.offAll(() => const MainScreen(selectedIndex: 3));
                  },
                  bgColor: blueColor,
                  isDisabled: isLoading,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Go Back & Change',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  isDisabled: isLoading,
                  textIconColor: blackColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: whiteColor,
          iconTheme: const IconThemeData(color: blackColor),
          centerTitle: true,
          title: const Text(
            'Update profile image',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
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
                      Ionicons.person,
                      color: whiteColor,
                      size: 45,
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
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Ionicons.alert_circle,
                                size: 30,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Center(
                                child: SpinKitFadingCircle(
                                  color: lightBlackColor,
                                  size: 30,
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
                onPressed: requestCameraPermission,
                icon: Ionicons.camera,
                bgColor: whiteColor,
                borderColor: blackColor,
                textIconColor: blackColor,
                isDisabled: isLoading,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomButton(
                text: 'Choose Photo',
                onPressed: requestGalleryPermission,
                icon: Ionicons.image,
                bgColor: whiteColor,
                borderColor: blackColor,
                textIconColor: blackColor,
                isDisabled: isLoading,
              ),
            ),
          ],
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
                  onPressed:
                      pickedImage != null ? showConfirmationDialog : () {},
                  icon: Ionicons.arrow_forward,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
        ),
      ),
    );
  }
}
