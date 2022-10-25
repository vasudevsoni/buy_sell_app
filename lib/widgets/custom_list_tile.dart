import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../utils/utils.dart';

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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.only(
            left: 10,
            top: 10,
            right: 10,
          ),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return const Icon(
                        Iconsax.warning_24,
                        size: 20,
                        color: redColor,
                      );
                    },
                    placeholder: (context, url) {
                      return const Center(
                        child: SpinKitFadingCube(
                          color: lightBlackColor,
                          size: 20,
                          duration: Duration(milliseconds: 1000),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              AutoSizeText(
                text,
                maxLines: 1,
                softWrap: true,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
