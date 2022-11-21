import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '/utils/utils.dart';
import 'svg_picture.dart';

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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: greyColor,
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SVGPictureWidget(
                  url: url,
                  fit: BoxFit.contain,
                  semanticsLabel: 'category image',
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
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
