import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonWithoutIcon extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;
  final Color borderColor;
  final bool isDisabled;
  final Color textIconColor;

  const CustomButtonWithoutIcon({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    required this.bgColor,
    required this.borderColor,
    required this.textIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        enableFeedback: true,
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        splashFactory: InkRipple.splashFactory,
        animationDuration: const Duration(milliseconds: 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: borderColor,
            strokeAlign: StrokeAlign.inside,
            width: 1.2,
          ),
        ),
      ),
      child: AutoSizeText(
        text,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: GoogleFonts.sora(
          color: textIconColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
