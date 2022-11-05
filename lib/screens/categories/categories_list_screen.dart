import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/firebase_services.dart';
import '../../screens/categories/sub_categories_list_screen.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_list_tile.dart';

class CategoriesListScreen extends StatelessWidget {
  static const String routeName = '/categories-list-screen';
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseServices service = FirebaseServices();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'All categories',
          style: GoogleFonts.poppins(
            color: blackColor,
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
                child: Text('Erorr loading categories.'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: SpinKitFadingCube(
                    color: lightBlackColor,
                    size: 20,
                    duration: Duration(milliseconds: 1000),
                  ),
                ),
              );
            }
            return Scrollbar(
              interactive: true,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1 / 1,
                ),
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                padding: const EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  return CustomListTile(
                    text: doc['catName'],
                    url: doc['image'],
                    onTap: () {
                      Get.to(() => SubCategoriesListScreen(doc: doc));
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
