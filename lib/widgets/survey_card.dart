import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../utils/utils.dart';
import 'custom_button_without_icon.dart';

class SurveyCard extends StatelessWidget {
  const SurveyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: whiteColor,
        border: greyBorder,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Ionicons.flash_outline,
                    color: greenColor,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Participate in our survey',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: size.width * 0.6,
                child: AutoSizeText(
                  'Help us improve BechDe by filling this survey.',
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          CustomButtonWithoutIcon(
            text: 'Go',
            onPressed: () => showSurveyPopUp(context),
            borderColor: blueColor,
            bgColor: blueColor,
            textIconColor: whiteColor,
          ),
        ],
      ),
    );
  }
}
