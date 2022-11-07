import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

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
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: ShapeDecoration(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: borderColor,
              strokeAlign: StrokeAlign.center,
              width: 1.2,
            ),
          ),
          color: bgColor,
        ),
        width: MediaQuery.of(context).size.width,
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
                  fontSize: 14,
                  color: textIconColor,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Icon(
                icon,
                color: textIconColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
