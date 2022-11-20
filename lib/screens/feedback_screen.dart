import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/text_field_label.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_text_field.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseServices services = FirebaseServices();
  final TextEditingController feedbackTextController = TextEditingController();

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
            padding: const EdgeInsets.only(
              top: 5,
              left: 15,
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
                    'Submit feedback?',
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
                    'Are you sure you want to submit this feedback?',
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
                  text: 'Yes, Submit',
                  onPressed: () async {
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    AndroidDeviceInfo androidInfo =
                        await deviceInfo.androidInfo;
                    services.submitFeedback(
                      text: feedbackTextController.text,
                      model: androidInfo.model,
                      androidVersion: androidInfo.version.release,
                      securityPatch: androidInfo.version.securityPatch,
                    );
                    Get.back();
                    setState(() {
                      feedbackTextController.clear();
                    });
                    Get.back();
                  },
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
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
    feedbackTextController.dispose();
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
          'Give feedback',
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
            const TextFieldLabel(labelText: 'Write your feedback'),
            CustomTextField(
              controller: feedbackTextController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              showCounterText: true,
              maxLength: 1000,
              maxLines: 3,
              hint: 'Explain your feedback in a few words',
            ),
            const Spacer(),
            CustomButton(
              icon: Ionicons.arrow_forward,
              text: 'Proceed',
              onPressed: () {
                if (feedbackTextController.text.isEmpty) {
                  return;
                }
                showConfirmation();
              },
              bgColor: blueColor,
              borderColor: blueColor,
              textIconColor: whiteColor,
            ),
          ],
        ),
      ),
    );
  }
}
