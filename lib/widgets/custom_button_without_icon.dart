import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        onPressed();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: borderColor,
            strokeAlign: StrokeAlign.center,
            width: 1.2,
          ),
          color: bgColor,
        ),
        child: Center(
          child: AutoSizeText(
            text,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: textIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
