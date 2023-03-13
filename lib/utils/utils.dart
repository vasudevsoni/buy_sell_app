import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
      boxShadows: const [
        BoxShadow(
          blurRadius: 20,
          spreadRadius: 2,
          color: lightBlackColor,
        ),
      ],
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      dismissDirection: DismissDirection.up,
      snackPosition: SnackPosition.TOP,
    ),
  );
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

const blueColor = Color(0xff1a6ed8);
const whiteColor = Color(0xffffffff);
const redColor = Color(0xffe01212);
const blackColor = Color(0xff190101);
const greyColor = Color(0xffecf1f6);
const greenColor = Color(0xff34a853);
const transparentColor = Colors.transparent;
const lightBlackColor = Colors.black54;
const fadedColor = Colors.black45;
