import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/utils.dart';

class SVGPictureWidget extends StatelessWidget {
  final String url;
  final String semanticsLabel;
  final BoxFit fit;
  const SVGPictureWidget({
    super.key,
    required this.url,
    required this.semanticsLabel,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      fit: fit,
      semanticsLabel: semanticsLabel,
      placeholderBuilder: (context) {
        return const Center(
          child: SpinKitFadingCircle(
            color: greyColor,
            size: 30,
            duration: Duration(milliseconds: 1000),
          ),
        );
      },
    );
  }
}
