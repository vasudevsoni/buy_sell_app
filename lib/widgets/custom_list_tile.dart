import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';

// ignore: must_be_immutable
class CustomListTile extends StatelessWidget {
  final String text;
  final String url;
  final IconData icon;
  void Function()? onTap;
  CustomListTile({
    super.key,
    required this.text,
    required this.url,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        height: 60,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: greyColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.08,
              width: MediaQuery.of(context).size.width * 0.08,
              child: SvgPicture.network(
                url,
                fit: BoxFit.contain,
                color: fadedColor,
                placeholderBuilder: (context) {
                  return const Center(
                    child: SpinKitFadingCube(
                      color: blueColor,
                      size: 30,
                      duration: Duration(milliseconds: 1000),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}
