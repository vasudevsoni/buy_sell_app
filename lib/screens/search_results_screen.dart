import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_services.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_product_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final FirebaseServices _services = FirebaseServices();
  bool isLocationEmpty = false;
  String city = '';

  @override
  void initState() {
    _services.getCurrentUserData().then((value) {
      if (value['location'] == null) {
        setState(() {
          isLocationEmpty = true;
        });
      } else {
        setState(() {
          city = value['location']['city'];
          isLocationEmpty = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: Text(
            widget.query,
            style: GoogleFonts.poppins(
              color: blackColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              FirestoreQueryBuilder(
                query: isLocationEmpty
                    ? _services.listings
                        .where('searchQueries', arrayContains: widget.query)
                        .where('isActive', isEqualTo: true)
                        .orderBy('postedAt', descending: true)
                    : _services.listings
                        .where('searchQueries', arrayContains: widget.query)
                        .where('isActive', isEqualTo: true)
                        .orderBy('postedAt', descending: true)
                        .where('location.city', isEqualTo: city),
                pageSize: 6,
                builder: (context, snapshot, child) {
                  if (snapshot.isFetching) {
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
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Something has gone wrong. Please try again',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.heartCrack,
                              size: 60,
                              color: pinkColor,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'No results found',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 15,
                          ),
                          child: Text(
                            isLocationEmpty ? 'Results' : 'Results in $city',
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 13,
                            );
                          },
                          padding: const EdgeInsets.only(
                            left: 15,
                            top: 10,
                            right: 15,
                            bottom: 30,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.docs.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.docs[index];
                            var time = DateTime.fromMillisecondsSinceEpoch(
                                data['postedAt']);
                            var sellerDetails =
                                _services.getUserData(data['sellerUid']);
                            final hasMoreReached = snapshot.hasMore &&
                                index + 1 == snapshot.docs.length &&
                                !snapshot.isFetchingMore;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomProductCard(
                                  data: data,
                                  sellerDetails: sellerDetails,
                                  time: time,
                                ),
                                if (hasMoreReached)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (hasMoreReached)
                                  CustomButton(
                                    text: 'Load more',
                                    onPressed: () => snapshot.fetchMore(),
                                    icon: FontAwesomeIcons.chevronDown,
                                    borderColor: blackColor,
                                    bgColor: blackColor,
                                    textIconColor: whiteColor,
                                  ),
                              ],
                            );
                          },
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
