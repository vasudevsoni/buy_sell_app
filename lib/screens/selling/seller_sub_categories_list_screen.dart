import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '/utils/utils.dart';
import '/widgets/custom_list_tile_no_image.dart';
import '/services/firebase_services.dart';
import 'common/ad_post_screen.dart';
import 'vehicles/vehicle_ad_post_screen.dart';

class SellerSubCategoriesListScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const SellerSubCategoriesListScreen({
    super.key,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final FirebaseServices service = FirebaseServices();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Select a sub category in ${doc['catName']}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SizedBox(
        height: size.height,
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
                  child: SpinKitFadingCircle(
                    color: lightBlackColor,
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
              itemBuilder: (context, index) {
                return CustomListTileNoImage(
                  text: data[index],
                  trailingIcon: Ionicons.chevron_forward,
                  isEnabled: true,
                  onTap: () {
                    if (doc['catName'] == 'Vehicles') {
                      Get.offAll(
                        () => VehicleAdPostScreen(subCatName: data[index]),
                        transition: Transition.downToUp,
                      );
                      return;
                    }
                    Get.offAll(
                      () => AdPostScreen(
                          catName: doc['catName'], subCatName: data[index]),
                      transition: Transition.downToUp,
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
