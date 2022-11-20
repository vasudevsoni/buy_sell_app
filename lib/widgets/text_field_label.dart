import 'package:flutter/cupertino.dart';

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
          style: const TextStyle(
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
