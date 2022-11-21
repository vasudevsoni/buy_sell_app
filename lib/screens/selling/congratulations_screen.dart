import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/screens/main_screen.dart';

class CongratulationsScreen extends StatefulWidget {
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
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: transparentColor,
            elevation: 0.0,
            actions: [
              IconButton(
                onPressed: () =>
                    Get.offAll(() => const MainScreen(selectedIndex: 0)),
                icon: const Icon(
                  Ionicons.close_circle_outline,
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
                    pinkColor,
                    blackColor,
                  ],
                  blastDirectionality: BlastDirectionality.directional,
                  emissionFrequency: 0,
                  blastDirection: pi / -2,
                  numberOfParticles: 80,
                ),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greyColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: const Text(
                    'Your product will be live once it is reviewed.',
                    style: TextStyle(
                      fontSize: 15,
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
                const Text(
                  'Sit back and relax.😊',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () =>
                      Get.offAll(() => const MainScreen(selectedIndex: 0)),
                  icon: Ionicons.home,
                  bgColor: blueColor,
                  borderColor: blueColor,
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
