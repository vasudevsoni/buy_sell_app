import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void showSnackBar({
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
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: whiteColor,
        ),
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.GROUNDED,
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

const transparentColor = Colors.transparent;
const whiteColor = Color(0xffffffff);
const pinkColor = Color(0xffff4d6d);
const redColor = Color(0xffe5383b);
const blueColor = Color(0xff4895ef);
const blackColor = Color(0xff190101);
const lightBlackColor = Colors.black54;
const fadedColor = Colors.black45;
const greyColor = Color(0xffecf1f6);
const googleLoginColor = Color(0xff4285F4);
