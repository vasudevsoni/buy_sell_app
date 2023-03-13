import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../widgets/custom_loading_indicator.dart';
import '/services/firebase_services.dart';
import '/screens/categories/sub_categories_list_screen.dart';
import '/widgets/custom_list_tile.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

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
    return StreamBuilder<QuerySnapshot>(
      stream: service.categories
          .orderBy(
            'sortId',
            descending: false,
          )
          .snapshots(),
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
          physics: const ClampingScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.all(15),
          itemBuilder: (context, index) {
            var doc = docs[index];
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
