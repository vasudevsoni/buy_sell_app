import 'package:flutter/material.dart';

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
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
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
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: lightBlackColor,
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
