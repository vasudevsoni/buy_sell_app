import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:buy_sell_app/widgets/svg_picture.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'utils/utils.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(15),
              height: size.height * 0.3,
              width: size.width,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: greyColor,
              ),
              child: const SVGPictureWidget(
                url:
                    'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FBeep%20Beep%20-%20UFO.svg?alt=media&token=4c178203-bb92-4391-b773-942eb26e6012',
                fit: BoxFit.contain,
                semanticsLabel: 'Error picture',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Uh-oh! Looks like you are lost in space!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CustomButton(
                text: 'Go to Home',
                onPressed: () => Get.offAll(
                  () => const MainScreen(selectedIndex: 0),
                ),
                icon: Ionicons.home,
                borderColor: blueColor,
                bgColor: blueColor,
                textIconColor: whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
