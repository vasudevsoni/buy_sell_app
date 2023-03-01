import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'search_results_screen.dart';
import '/widgets/custom_text_field.dart';
import '/utils/utils.dart';

class SearchFieldScreen extends StatefulWidget {
  const SearchFieldScreen({super.key});

  @override
  State<SearchFieldScreen> createState() => _SearchFieldScreenState();
}

class _SearchFieldScreenState extends State<SearchFieldScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Search',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomTextField(
              controller: searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              autofocus: true,
              hint: 'Search for mobiles, cars, dresses and more...',
              maxLength: 50,
              onFieldSubmitted: (query) {
                query.length > 2
                    ? Get.to(
                        () => SearchResultsScreen(query: query),
                      )
                    : null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
