import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSnackBar({
  required BuildContext context,
  required String content,
  required Color color,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
      backgroundColor: color,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

const redColor = Color(0xffe5383b);
const blueColor = Color(0xff4361ee);
const blackColor = Color(0xff190101);
const lightBlackColor = Colors.black54;
const fadedColor = Colors.black45;
const greyColor = Color(0xffe9ecef);
