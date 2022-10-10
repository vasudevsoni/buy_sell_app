import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  String text;
  final VoidCallback onPressed;
  IconData icon;
  Color bgColor;
  bool isDisabled;
  Color textIconColor;

  CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.isDisabled = false,
    required this.bgColor,
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
        side: const BorderSide(
          width: 1.5,
          color: blackColor,
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
          const Spacer(),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textIconColor,
            ),
          ),
          const Spacer(),
          Icon(
            icon,
            color: textIconColor,
            size: 18,
          ),
        ],
      ),
    );
  }
}
