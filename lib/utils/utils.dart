import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void showSnackBar({
  required final String content,
  required Color color,
}) {
  Get.closeCurrentSnackbar();
  Get.showSnackbar(
    GetSnackBar(
      messageText: Text(
        content,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: GoogleFonts.interTight(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: whiteColor,
        ),
      ),
      animationDuration: kThemeAnimationDuration,
      backgroundColor: color,
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.FLOATING,
      boxShadows: const [customShadow],
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      dismissDirection: DismissDirection.up,
      snackPosition: SnackPosition.TOP,
    ),
  );
}

void showSurveyPopUp(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasShownPopup = prefs.getBool('isSurveyPopupShown') ?? false;

  if (!hasShownPopup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: lightBlackColor,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "👋 Hey! Do you have a minute to spare?",
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          content: Text(
            "We would love to hear your feedback. Please take a moment to fill out our survey. 😊",
            style: GoogleFonts.interTight(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: blackColor,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            OutlinedButton(
              child: Text(
                "Maybe later",
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blackColor,
                elevation: 0,
              ),
              child: Text(
                "Take Survey",
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w600,
                  color: whiteColor,
                ),
              ),
              onPressed: () {
                launchUrl(
                  Uri.parse(
                      'https://docs.google.com/forms/d/e/1FAIpQLSe5G68ParoPNZMo4nySwtqD7Mp2tOaWcTaxhog9MejyYa2Ydg/viewform?usp=sf_link'),
                  mode: LaunchMode.externalApplication,
                );
                prefs.setBool('isSurveyPopupShown', true);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}

final priceFormat = NumberFormat.currency(
  locale: 'HI',
  decimalDigits: 0,
  symbol: '₹',
  name: '',
);

final kmFormat = NumberFormat.currency(
  locale: 'HI',
  decimalDigits: 0,
  symbol: '',
  name: '',
);

const Color blueColor = Color(0xff3454D1);
const Color whiteColor = Color(0xffffffff);
const Color redColor = Color(0xffEE4266);
const Color blackColor = Color(0xff190101);
const Color greyColor = Color(0xffecf1f6);
const Color greenColor = Color(0xff34a853);
const Color transparentColor = Colors.transparent;
const Color lightBlackColor = Colors.black54;
const Color fadedColor = Colors.black45;

const BoxShadow customShadow = BoxShadow(
  color: lightBlackColor,
  spreadRadius: 0.1,
  blurRadius: 2,
  blurStyle: BlurStyle.normal,
  offset: Offset(0, 2),
);

final Border greyBorder = Border.all(
  color: greyColor,
  width: 0.7,
);

final NativeTemplateStyle smallNativeAdStyle = NativeTemplateStyle(
  templateType: TemplateType.small,
  mainBackgroundColor: whiteColor,
  cornerRadius: 10,
  callToActionTextStyle: NativeTemplateTextStyle(
    textColor: whiteColor,
    backgroundColor: blueColor,
    style: NativeTemplateFontStyle.bold,
    size: 15,
  ),
  primaryTextStyle: NativeTemplateTextStyle(
    textColor: blackColor,
    style: NativeTemplateFontStyle.bold,
    size: 15,
  ),
  secondaryTextStyle: NativeTemplateTextStyle(
    textColor: blueColor,
    style: NativeTemplateFontStyle.italic,
    size: 14,
  ),
  tertiaryTextStyle: NativeTemplateTextStyle(
    textColor: blackColor,
    style: NativeTemplateFontStyle.normal,
    size: 15,
  ),
);

final NativeTemplateStyle mediumNativeAdStyle = NativeTemplateStyle(
  templateType: TemplateType.medium,
  mainBackgroundColor: whiteColor,
  cornerRadius: 10,
  callToActionTextStyle: NativeTemplateTextStyle(
    textColor: whiteColor,
    backgroundColor: blueColor,
    style: NativeTemplateFontStyle.bold,
    size: 15,
  ),
  primaryTextStyle: NativeTemplateTextStyle(
    textColor: blackColor,
    style: NativeTemplateFontStyle.bold,
    size: 15,
  ),
  secondaryTextStyle: NativeTemplateTextStyle(
    textColor: blueColor,
    style: NativeTemplateFontStyle.italic,
    size: 14,
  ),
  tertiaryTextStyle: NativeTemplateTextStyle(
    textColor: blackColor,
    style: NativeTemplateFontStyle.normal,
    size: 15,
  ),
);
