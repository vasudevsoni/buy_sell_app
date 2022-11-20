import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 1000),
      height: 48,
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: SpinKitFadingCircle(
          color: whiteColor,
          size: 30,
          duration: Duration(milliseconds: 1000),
        ),
      ),
    );
  }
}
