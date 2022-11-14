import 'package:flutter/material.dart';

import '/utils/utils.dart';

class FullDescriptionScreen extends StatelessWidget {
  final String desc;
  const FullDescriptionScreen({
    super.key,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            desc,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
