import 'package:flutter/material.dart';

import '/utils/utils.dart';

class FullBioScreen extends StatelessWidget {
  final String bio;
  const FullBioScreen({
    super.key,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Bio',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            bio,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
