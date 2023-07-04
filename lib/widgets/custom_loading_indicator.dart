import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.twoRotatingArc(
        color: blueColor,
        size: 25,
      ),
    );
  }
}
