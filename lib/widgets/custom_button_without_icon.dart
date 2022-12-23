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
    final size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        elevation: 0,
        splashFactory: InkRipple.splashFactory,
        enableFeedback: true,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        fixedSize: Size(size.width, 45),
        side: BorderSide(
          color: borderColor,
          strokeAlign: StrokeAlign.center,
          width: 1.2,
        ),
      ),
      onPressed: () {
        HapticFeedback.vibrate();
        onPressed();
      },
      child: AutoSizeText(
        text,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textIconColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
    );
  }
}
