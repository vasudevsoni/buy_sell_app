import 'package:flutter/material.dart';
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: textIconColor,
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        enableFeedback: true,
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        fixedSize: isFullWidth == true
            ? Size.fromWidth(MediaQuery.of(context).size.width)
            : null,
        splashFactory: InkRipple.splashFactory,
        animationDuration: const Duration(milliseconds: 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: borderColor,
            strokeAlign: StrokeAlign.inside,
            width: 1.2,
          ),
        ),
      ),
      label: Text(
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
