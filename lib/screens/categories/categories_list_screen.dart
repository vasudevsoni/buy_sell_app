import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '/services/firebase_services.dart';
import '/screens/categories/sub_categories_list_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_list_tile.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen>
    with AutomaticKeepAliveClientMixin {
  final FirebaseServices service = FirebaseServices();
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<QuerySnapshot>(
      future: service.categories
          .orderBy(
            'sortId',
            descending: false,
          )
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading categories'),
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
          physics: const ClampingScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.all(15),
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
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
    );
  }
}
