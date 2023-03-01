import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/utils.dart';

class CustomListTileNoImage extends StatelessWidget {
  final String text;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isEnabled;
  final void Function()? onTap;

  const CustomListTileNoImage({
    super.key,
    required this.text,
    this.icon,
    this.trailingIcon,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.interTight(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: isEnabled ? onTap : null,
      dense: true,
      trailing: Icon(
        trailingIcon,
        size: 15,
        color: lightBlackColor,
      ),
      minLeadingWidth: icon == null ? 0 : 40,
      leading: icon == null
          ? null
          : Icon(
              icon,
              size: 22,
              color: blackColor,
            ),
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
