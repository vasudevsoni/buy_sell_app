import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final bool? isFullWidth;
  final bool isDisabled;
  final Color textIconColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
    required this.borderColor,
    this.isDisabled = false,
    this.isFullWidth = false,
    required this.bgColor,
    required this.textIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GFButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: textIconColor,
      ),
      borderShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: borderColor,
          strokeAlign: StrokeAlign.inside,
          width: 1.2,
        ),
      ),
      splashColor: transparentColor,
      color: bgColor,
      enableFeedback: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      size: GFSize.LARGE,
      fullWidthButton: isFullWidth,
      animationDuration: const Duration(milliseconds: 100),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: GoogleFonts.interTight(
          color: textIconColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
