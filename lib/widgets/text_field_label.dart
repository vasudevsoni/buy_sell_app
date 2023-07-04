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
          style: GoogleFonts.interTight(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
