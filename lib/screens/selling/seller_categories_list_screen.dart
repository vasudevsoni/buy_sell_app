import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/firebase_services.dart';
import '../../widgets/custom_list_tile.dart';
import '../../screens/selling/seller_sub_categories_list_screen.dart';

class SellerCategoriesListScreen extends StatelessWidget {
  static const String routeName = '/seller-categories-list-screen';
  const SellerCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseServices service = FirebaseServices();

    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Select a category',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<QuerySnapshot>(
          future: service.categories
              .orderBy(
                'sortId',
                descending: false,
              )
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Erorr loading categories'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text('Loading...'),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return CustomListTile(
                  text: doc['catName'],
                  url: doc['image'],
                  icon: FontAwesomeIcons.chevronRight,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SellerSubCategoriesListScreen(doc: doc),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
