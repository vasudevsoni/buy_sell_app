import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../utils/utils.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const GFLoader(
      type: GFLoaderType.circle,
      duration: Duration(milliseconds: 1000),
      loaderColorOne: blueColor,
      loaderColorTwo: blackColor,
      loaderColorThree: blueColor,
    );
  }
}
