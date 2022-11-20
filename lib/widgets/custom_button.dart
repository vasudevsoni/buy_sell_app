import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final bool isDisabled;
  final Color textIconColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
    required this.borderColor,
    this.isDisabled = false,
    required this.bgColor,
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
            strokeAlign: StrokeAlign.inside,
            width: 1.2,
          ),
          color: bgColor,
        ),
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Center(
              child: AutoSizeText(
                text,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textIconColor,
                  fontSize: 14.5,
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Icon(
                icon,
                color: textIconColor,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
