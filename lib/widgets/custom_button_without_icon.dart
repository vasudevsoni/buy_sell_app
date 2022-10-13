import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class CustomButtonWithoutIcon extends StatelessWidget {
  String text;
  final VoidCallback onPressed;
  Color bgColor;
  Color borderColor;
  bool isDisabled;
  Color textIconColor;

  CustomButtonWithoutIcon({
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
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(
          width: 1,
          color: borderColor,
          strokeAlign: StrokeAlign.inside,
          style: BorderStyle.solid,
        ),
        fixedSize: Size(
          MediaQuery.of(context).size.width,
          50,
        ),
      ),
      child: SizedBox(
        child: AutoSizeText(
          text,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textIconColor,
          ),
        ),
      ),
    );
  }
}
