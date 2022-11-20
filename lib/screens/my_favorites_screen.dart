import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';
import '/utils/utils.dart';
import '/widgets/my_favorites_products_list.dart';

class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProv = Provider.of<MainProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        mainProv.switchToPage(0);
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: whiteColor,
          iconTheme: const IconThemeData(color: blackColor),
          centerTitle: true,
          title: const Text(
            'My favorites',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 15,
            ),
          ),
        ),
        body: const MyFavoritesProductsList(),
      ),
    );
  }
}
