import 'package:flutter/material.dart';

import '/utils/utils.dart';
import '/widgets/my_listings_list.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: whiteColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'My products',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: const MyListingsList(),
    );
  }
}
