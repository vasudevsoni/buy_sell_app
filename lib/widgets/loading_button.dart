import 'package:flutter/material.dart';
// import 'package:getwidget/getwidget.dart';

import 'custom_loading_indicator.dart';

class LoadingButton extends StatelessWidget {
  final Color bgColor;
  const LoadingButton({
    super.key,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        enableFeedback: true,
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        splashFactory: InkRipple.splashFactory,
        animationDuration: const Duration(milliseconds: 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: const Center(
        child: CustomLoadingIndicator(),
      ),
    );
  }
}
