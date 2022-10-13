import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isEnabled;
  final bool showCounterText;
  final bool autofocus;
  final String? prefixText;
  final bool isObscured;
  final String label;
  final String hint;
  final int maxLength;
  final int maxLines;
  String? Function(String?)? validator;
  Function(String)? onChanged;
  CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    this.isEnabled = true,
    this.showCounterText = false,
    required this.label,
    this.isObscured = false,
    required this.hint,
    this.autofocus = false,
    this.prefixText,
    required this.maxLength,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      enabled: isEnabled,
      autofocus: autofocus,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      obscureText: isObscured,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: blackColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        hintText: hint,
        prefixText: prefixText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        fillColor: greyColor,
        filled: true,
        counterText: showCounterText ? null : '',
        counterStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fadedColor,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: blueColor,
            width: 1.5,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: blueColor,
            width: 1.5,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color.fromARGB(255, 111, 111, 111),
        ),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}
