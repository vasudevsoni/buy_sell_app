import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return const Icon(
                    FontAwesomeIcons.circleExclamation,
                    size: 20,
                    color: redColor,
                  );
                },
                placeholder: (context, url) {
                  return const Center(
                    child: SpinKitFadingCircle(
                      color: lightBlackColor,
                      size: 20,
                      duration: Duration(milliseconds: 1000),
                    ),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: AutoSizeText(
                text,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 35,
                  color: whiteColor,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 10.0,
                      color: lightBlackColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
