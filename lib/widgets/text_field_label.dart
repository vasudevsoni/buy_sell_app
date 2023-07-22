import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldLabel extends StatelessWidget {
  final String labelText;
  const TextFieldLabel({
    super.key,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
