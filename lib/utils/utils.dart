import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSnackBar({
  required BuildContext context,
  required String content,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 0,
      backgroundColor: blueColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

const blueColor = Color(0xff4361ee);
const blackColor = Color(0xff190101);
const lightBlackColor = Colors.black54;
const fadedColor = Colors.black45;
const greyColor = Color(0xffe9ecef);