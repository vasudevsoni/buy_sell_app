import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class ExternalLinkIcon extends StatelessWidget {
  final String link;
  final IconData icon;
  final Color iconColor;
  const ExternalLinkIcon({
    Key? key,
    required this.link,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Link(
      target: LinkTarget.blank,
      uri: Uri.parse(link),
      builder: (context, followLink) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: followLink,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(50),
              border: greyBorder,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),
        );
      },
    );
  }
}
