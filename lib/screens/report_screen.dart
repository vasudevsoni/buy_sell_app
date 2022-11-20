import 'dart:io';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/text_field_label.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseServices services = FirebaseServices();
  final TextEditingController reportTextController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  File? reportImage;

  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      reportImage = File(pickedFile.path);
    });
  }

  void requestGalleryPermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      getImageFromGallery();
    } else if (status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        getImageFromGallery();
      } else {
        showSnackBar(
          content: 'Storage permission is required to upload pictures',
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

  showConfirmation() {
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                const Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
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
                    'Are you sure you want to send this report?',
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
                  text: 'Yes, Send Report',
                  onPressed: () async {
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    AndroidDeviceInfo androidInfo =
                        await deviceInfo.androidInfo;
                    services.reportAProblem(
                      text: reportTextController.text,
                      screenshot: reportImage,
                      androidVersion: androidInfo.version.release,
                      model: androidInfo.model,
                      securityPatch: androidInfo.version.securityPatch,
                    );
                    Get.back();
                    setState(() {
                      reportImage == null;
                      reportTextController.clear();
                    });
                    Get.back();
                  },
                  bgColor: whiteColor,
                  borderColor: redColor,
                  textIconColor: redColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'No, Cancel',
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

  @override
  void dispose() {
    reportTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Report a problem',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextFieldLabel(labelText: 'Explain your problem'),
            CustomTextField(
              controller: reportTextController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              showCounterText: true,
              maxLength: 1000,
              maxLines: 3,
              // label: 'Message',
              hint: 'Briefly explain what happened or what\'s not working',
            ),
            const SizedBox(
              height: 10,
            ),
            const TextFieldLabel(
                labelText: 'Upload a screenshot of the problem'),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: requestGalleryPermission,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: greyColor,
                ),
                height: 100,
                width: 100,
                child: reportImage == null
                    ? const Icon(
                        Ionicons.cloud_upload,
                        color: lightBlackColor,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              reportImage!,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Ionicons.alert_circle,
                                  size: 20,
                                  color: redColor,
                                );
                              },
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: IconButton(
                                tooltip: 'Delete image',
                                onPressed: () {
                                  setState(() {
                                    reportImage = null;
                                  });
                                },
                                icon: const Icon(
                                  Ionicons.close_circle_outline,
                                  size: 15,
                                  color: whiteColor,
                                  shadows: [
                                    BoxShadow(
                                      offset: Offset(0, 0),
                                      blurRadius: 5,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const Spacer(),
            CustomButton(
              icon: Ionicons.arrow_forward,
              text: 'Send Report',
              onPressed: () {
                if (reportTextController.text.isEmpty || reportImage == null) {
                  return;
                }
                showConfirmation();
              },
              bgColor: redColor,
              borderColor: redColor,
              textIconColor: whiteColor,
            ),
          ],
        ),
      ),
    );
  }
}
