import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../utils/utils.dart';
import 'custom_loading_indicator.dart';

class LoadingButton extends StatelessWidget {
  final Color bgColor;
  const LoadingButton({
    super.key,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GFButton(
      onPressed: null,
      borderShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      splashColor: transparentColor,
      color: bgColor,
      enableFeedback: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      size: GFSize.LARGE,
      animationDuration: const Duration(milliseconds: 1000),
      child: const Center(
        child: CustomLoadingIndicator(),
      ),
    );
  }
}
