import 'dart:io';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets/custom_button.dart';
import 'widgets/custom_button_without_icon.dart';
import 'widgets/custom_text_field.dart';

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

  Future pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      reportImage = File(pickedFile.path);
    });
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
                    services.feedbackToFirestore(
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
            const Text(
              'Explain your problem',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: blackColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: reportTextController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              showCounterText: true,
              maxLength: 1000,
              maxLines: 3,
              label: 'Message',
              hint: 'Briefly explain what happened or what\'s not working',
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Upload a screenshot of the problem',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: blackColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: pickImage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: greyColor,
                ),
                height: 100,
                width: 100,
                child: reportImage == null
                    ? const Icon(
                        FontAwesomeIcons.upload,
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
                                  FontAwesomeIcons.circleExclamation,
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
                                  FontAwesomeIcons.circleXmark,
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
              icon: FontAwesomeIcons.bug,
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
