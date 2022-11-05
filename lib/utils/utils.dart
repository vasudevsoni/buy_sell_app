import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

showSnackBar({
  required BuildContext context,
  required String content,
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
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: whiteColor,
        ),
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.GROUNDED,
      snackPosition: SnackPosition.TOP,
    ),
  );
}

const whiteColor = Color(0xffffffff);
const pinkColor = Color(0xffff4d6d);
const redColor = Color(0xffe5383b);
const blueColor = Color(0xff4895ef);
const blackColor = Color(0xff190101);
const lightBlackColor = Colors.black54;
const fadedColor = Colors.black45;
const greyColor = Color(0xffecf1f6);
const googleLoginColor = Color(0xffea4335);
