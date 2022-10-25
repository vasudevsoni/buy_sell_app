import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  String text;
  final VoidCallback onPressed;
  IconData icon;
  Color bgColor;
  Color borderColor;
  bool isDisabled;
  Color textIconColor;

  CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
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
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
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
      child: Row(
        children: [
          Expanded(
            flex: 15,
            child: AutoSizeText(
              text,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textIconColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              icon,
              color: textIconColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
