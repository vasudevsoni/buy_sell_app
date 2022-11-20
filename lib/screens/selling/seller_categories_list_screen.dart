import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/widgets/custom_list_tile.dart';
import '/screens/selling/seller_sub_categories_list_screen.dart';

class SellerCategoriesListScreen extends StatelessWidget {
  const SellerCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseServices service = FirebaseServices();

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Select a category',
          style: TextStyle(
            fontWeight: FontWeight.w500,
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
                child: Text('Erorr loading categories'),
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
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.3 / 1,
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
                  onTap: () => Get.to(
                    () => SellerSubCategoriesListScreen(doc: doc),
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
