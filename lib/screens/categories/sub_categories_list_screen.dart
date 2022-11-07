import 'package:buy_sell_app/screens/category_products_screen.dart';
import 'package:buy_sell_app/widgets/custom_list_tile_no_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          doc['catName'],
          style: GoogleFonts.poppins(
            color: blackColor,
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
                child: Text('Erorr loading sub-categories.'),
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
            var data = snapshot.data!['subCat'];
            return Scrollbar(
              interactive: true,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemBuilder: (context, index) {
                  return CustomListTileNoImage(
                    text: data[index],
                    icon: FontAwesomeIcons.chevronRight,
                    onTap: () => Get.to(
                      () => CategoryProductsScreen(
                        catName: doc['catName'],
                        subCatName: data[index],
                      ),
                    ),
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
