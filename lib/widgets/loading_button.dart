import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingButton extends StatelessWidget {
  final Color bgColor;
  const LoadingButton({
    super.key,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 1000),
      height: 45,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
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
