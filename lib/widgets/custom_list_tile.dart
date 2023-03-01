import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/utils.dart';

class CustomListTile extends StatelessWidget {
  final String text;
  final String url;
  final void Function()? onTap;

  const CustomListTile({
    super.key,
    required this.text,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: InkRipple.splashFactory,
      splashColor: fadedColor,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: whiteColor,
          border: Border.all(
            color: greyColor,
            width: 1,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: CachedNetworkImage(
                  imageUrl: url,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 10,
              ),
              child: AutoSizeText(
                text,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: blackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
