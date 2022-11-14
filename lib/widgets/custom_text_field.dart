import 'package:flutter/material.dart';

import '/utils/utils.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isEnabled;
  final bool showCounterText;
  final bool autofocus;
  final bool isReadOnly;
  final bool isObscured;
  final String label;
  final String hint;
  final int? maxLength;
  final void Function()? onTap;
  final Function(String)? onFieldSubmitted;
  final int maxLines;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    required this.keyboardType,
    required this.textInputAction,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.showCounterText = false,
    required this.label,
    this.onTap,
    this.onFieldSubmitted,
    this.isObscured = false,
    required this.hint,
    this.autofocus = false,
    this.maxLength,
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
      onTap: onTap,
      readOnly: isReadOnly,
      autofocus: autofocus,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      obscureText: isObscured,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: blackColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        fillColor: greyColor,
        filled: true,
        counterText: showCounterText ? null : '',
        counterStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fadedColor,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: transparentColor,
            width: 0,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: transparentColor,
            width: 0,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: redColor,
            width: 1.5,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: blueColor,
            width: 1.5,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: blueColor,
            width: 1.5,
            strokeAlign: StrokeAlign.inside,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        hintStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: fadedColor,
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: redColor,
        ),
        floatingLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: lightBlackColor,
        ),
      ),
    );
  }
}
