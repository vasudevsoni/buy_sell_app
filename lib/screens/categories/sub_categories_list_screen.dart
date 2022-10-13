import 'package:buy_sell_app/screens/category_products_screen.dart';
import 'package:buy_sell_app/widgets/custom_list_tile_no_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../services/firebase_services.dart';
import '../../utils/utils.dart';

class SubCategoriesListScreen extends StatelessWidget {
  static const String routeName = '/sub-categories-list-screen';
  final QueryDocumentSnapshot<Object?> doc;
  const SubCategoriesListScreen({
    super.key,
    required this.doc,
  });

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
          doc['catName'],
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<DocumentSnapshot>(
          future: service.categories.doc(doc.id).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Erorr loading sub-categories'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: SpinKitFadingCube(
                    color: blueColor,
                    size: 30,
                    duration: Duration(milliseconds: 1000),
                  ),
                ),
              );
            }
            var data = snapshot.data!['subCat'];
            return ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: data.length,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                return CustomListTileNoImage(
                  text: data[index],
                  icon: FontAwesomeIcons.chevronRight,
                  onTap: () => {
                    Navigator.of(context).push(
                      PageTransition(
                        child: CategoryProductsScreen(
                          catName: doc['catName'],
                          subCatName: data[index],
                        ),
                        type: PageTransitionType.rightToLeftWithFade,
                      ),
                    ),
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
