import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/utils.dart';

class CustomListTileWithSubtitle extends StatelessWidget {
  final String text;
  final String subTitle;
  final IconData icon;
  final IconData? trailingIcon;
  final bool isEnabled;
  final Color? textColor;
  final void Function()? onTap;

  const CustomListTileWithSubtitle({
    super.key,
    required this.text,
    this.subTitle = '',
    required this.icon,
    this.trailingIcon,
    this.textColor,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      onTap: isEnabled ? onTap : null,
      dense: true,
      trailing: Icon(
        trailingIcon,
        size: 15,
        color: lightBlackColor,
      ),
      subtitle: Text(
        subTitle,
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w500,
          color: blackColor,
          fontSize: 12,
        ),
      ),
      leading: Icon(
        icon,
        size: 22,
        color: blackColor,
      ),
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
