import 'package:buy_sell_app/screens/search_results_screen.dart';
import 'package:buy_sell_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class SearchFieldScreen extends StatefulWidget {
  static const String routeName = '/search-field-screen';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Search',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: CustomTextField(
              controller: searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              label: 'Search for anything',
              autofocus: true,
              hint: 'Start typing',
              maxLength: 50,
              onFieldSubmitted: (query) {
                query.length > 2
                    ? Navigator.of(context).push(
                        PageTransition(
                          child: SearchResultsScreen(query: query),
                          type: PageTransitionType.fade,
                        ),
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
