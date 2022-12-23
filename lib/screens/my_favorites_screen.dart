import 'package:flutter/material.dart';

import '/utils/utils.dart';
import '/widgets/my_favorites_products_list.dart';

class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: whiteColor,
      body: MyFavoritesProductsList(),
    );
  }
}
