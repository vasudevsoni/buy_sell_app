import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

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
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    MainScreen.routeName,
                  );
                },
                icon: const Icon(
                  Iconsax.close_circle4,
                  color: blackColor,
                  size: 30,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ConfettiWidget(
                  confettiController: controller,
                  shouldLoop: false,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 20,
                ),
                Text(
                  'Congratulations!',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Your listing is posted successfully.',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      MainScreen.routeName,
                    );
                  },
                  icon: Iconsax.home4,
                  bgColor: blackColor,
                  borderColor: blackColor,
                  textIconColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
