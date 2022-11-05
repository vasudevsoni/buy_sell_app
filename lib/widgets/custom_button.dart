import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
    required this.borderColor,
    this.isDisabled = false,
    required this.bgColor,
    required this.textIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: MediaQuery.of(context).size.width,
      child: NeumorphicButton(
        onPressed: isDisabled ? null : onPressed,
        style: NeumorphicStyle(
          lightSource: LightSource.top,
          shape: NeumorphicShape.convex,
          border: NeumorphicBorder(
            color: borderColor,
            width: 1,
          ),
          depth: 0,
          intensity: 0,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(5),
          ),
          color: bgColor,
        ),
        provideHapticFeedback: true,
        child: Row(
          children: [
            Expanded(
              flex: 15,
              child: AutoSizeText(
                text.toUpperCase(),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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
      ),
    );
  }
}
