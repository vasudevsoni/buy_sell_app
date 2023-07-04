import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/utils.dart';
import '../../widgets/custom_loading_indicator.dart';
import '/services/firebase_services.dart';
import '/screens/categories/sub_categories_list_screen.dart';
import '/widgets/custom_list_tile.dart';

class CategoriesListScreen extends StatelessWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final FirebaseServices service = FirebaseServices();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Categories',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w600,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SizedBox(
        height: size.height,
        child: StreamBuilder<QuerySnapshot>(
          stream: service.categories
              .orderBy(
                'sortId',
                descending: false,
              )
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading categories'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: CustomLoadingIndicator(),
                ),
              );
            }
            final docs = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.3 / 1,
              ),
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                final doc = docs[index];
                return CustomListTile(
                  text: doc['catName'],
                  url: doc['image'],
                  onTap: () => Get.to(
                    () => SubCategoriesListScreen(doc: doc),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
