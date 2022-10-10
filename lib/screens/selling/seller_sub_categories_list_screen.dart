import '../../widgets/custom_list_tile_no_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/firebase_services.dart';
import 'ad_post_screen.dart';
import 'vehicle_ad_post_screen.dart';

class SellerSubCategoriesListScreen extends StatelessWidget {
  static const String routeName = '/seller-sub-categories-list-screen';
  final QueryDocumentSnapshot<Object?> doc;
  const SellerSubCategoriesListScreen({
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
          'Select a sub category in ${doc['catName']}',
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
              return const Center(
                child: Text('Loading...'),
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
                  onTap: () {
                    if (doc['catName'] == 'Vehicles') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VehicleAdPostScreen(
                            subCatName: data[index],
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AdPostScreen(
                            catName: doc['catName'],
                            subCatName: data[index],
                          ),
                        ),
                      );
                    }
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
