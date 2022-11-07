import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../../screens/main_screen.dart';

class CongratulationsScreen extends StatefulWidget {
  static const String routeName = '/congratulations-screen';
  const CongratulationsScreen({super.key});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  final ConfettiController controller = ConfettiController();

  @override
  void initState() {
    controller.play();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: [
              IconButton(
                onPressed: () =>
                    Get.offAll(() => const MainScreen(selectedIndex: 0)),
                icon: const Icon(
                  FontAwesomeIcons.circleXmark,
                  color: blackColor,
                  size: 30,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ConfettiWidget(
                  confettiController: controller,
                  shouldLoop: false,
                  colors: const [
                    blueColor,
                    redColor,
                    Colors.yellow,
                  ],
                  blastDirectionality: BlastDirectionality.directional,
                  emissionFrequency: 0,
                  blastDirection: pi / -2,
                  numberOfParticles: 80,
                ),
                Text(
                  '🥳 Congratulations!',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: greyColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Text(
                    'Your listing will be live once it is reviewed.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Sit back and relax.😊',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () =>
                      Get.offAll(() => const MainScreen(selectedIndex: 0)),
                  icon: FontAwesomeIcons.house,
                  bgColor: blackColor,
                  borderColor: blackColor,
                  textIconColor: whiteColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
