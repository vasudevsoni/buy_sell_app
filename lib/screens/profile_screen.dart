import 'package:buy_sell_app/screens/full_bio_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../utils/utils.dart';
import '../widgets/custom_product_card.dart';
import '../services/firebase_services.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseServices services = FirebaseServices();
  String name = '';
  String bio = '';
  String profileImage = '';
  String sellerUid = '';
  DateTime dateJoined = DateTime.now();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await services.getUserData(widget.userId).then((value) {
      if (mounted) {
        setState(() {
          if (value['name'] == null) {
            name = 'Name not disclosed';
          } else {
            name = value['name'];
          }
          if (value['bio'] == null) {
            bio = '';
          } else {
            bio = value['bio'];
          }
          if (value['profileImage'] == null) {
            profileImage = '';
          } else {
            profileImage = value['profileImage'];
          }
          sellerUid = value['uid'];
          dateJoined = DateTime.fromMillisecondsSinceEpoch(value['dateJoined']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          interactive: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                profileImage == ''
                    ? Container(
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: blueColor,
                        ),
                        child: const Icon(
                          Iconsax.security_user4,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dismissible(
                                key: const Key('photoKey'),
                                direction: DismissDirection.down,
                                onDismissed: (direction) {
                                  Navigator.pop(context);
                                },
                                child: Material(
                                  color: Colors.black,
                                  child: Stack(
                                    children: [
                                      PhotoViewGallery.builder(
                                        scrollPhysics:
                                            const BouncingScrollPhysics(),
                                        itemCount: 1,
                                        builder:
                                            (BuildContext context, int index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: NetworkImage(
                                              profileImage,
                                            ),
                                            initialScale: PhotoViewComputedScale
                                                    .contained *
                                                1,
                                            minScale: PhotoViewComputedScale
                                                    .contained *
                                                1,
                                            maxScale: PhotoViewComputedScale
                                                    .contained *
                                                2,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Iconsax.warning_24,
                                                size: 20,
                                                color: redColor,
                                              );
                                            },
                                          );
                                        },
                                        loadingBuilder: (context, event) {
                                          return const Center(
                                            child: SpinKitFadingCube(
                                              color: greyColor,
                                              size: 20,
                                              duration:
                                                  Duration(milliseconds: 1000),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 15,
                                        left: 15,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          splashColor: blueColor,
                                          splashRadius: 30,
                                          icon: const Icon(
                                            Iconsax.close_square4,
                                            size: 30,
                                            color: Colors.white,
                                            shadows: [
                                              BoxShadow(
                                                offset: Offset(0, 0),
                                                blurRadius: 15,
                                                spreadRadius: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 0.3,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: profileImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    name,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: blackColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (bio != '')
                  Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            PageTransition(
                              child: FullBioScreen(bio: bio),
                              type: PageTransitionType.rightToLeftWithFade,
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'full-bio',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              bio,
                              maxLines: 3,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: blackColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                Text(
                  'Joined ${DateFormat.yMMMM().format(dateJoined)}',
                  style: GoogleFonts.poppins(
                    color: fadedColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const Divider(
                  height: 30,
                  color: fadedColor,
                  indent: 15,
                  endIndent: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Text(
                        'From this Seller',
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    SellerProductsList(
                      sellerUid: sellerUid,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SellerProductsList extends StatefulWidget {
  final String sellerUid;
  const SellerProductsList({
    super.key,
    required this.sellerUid,
  });

  @override
  State<SellerProductsList> createState() => _SellerProductsListState();
}

class _SellerProductsListState extends State<SellerProductsList> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );

    return FirestoreQueryBuilder(
      query: _services.listings
          .orderBy(
            'postedAt',
            descending: true,
          )
          .where('sellerUid', isEqualTo: widget.sellerUid),
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
                'Some error occurred. Please try again',
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
              child: Text(
                'No listings from this seller',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else {
          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            padding: const EdgeInsets.only(
              left: 10,
              top: 0,
              right: 10,
              bottom: 30,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.docs[index];
              var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
              var sellerDetails = _services.getUserData(data['sellerUid']);
              final hasEndReached = snapshot.hasMore &&
                  index + 1 == snapshot.docs.length &&
                  !snapshot.isFetchingMore;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomProductCard(
                    data: data,
                    sellerDetails: sellerDetails,
                    priceFormat: priceFormat,
                    time: time,
                  ),
                  if (hasEndReached)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromHeight(70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          snapshot.fetchMore();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Load more',
                              style: GoogleFonts.poppins(
                                color: blueColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              Iconsax.arrow_square_down4,
                              size: 15,
                              color: blueColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            physics: const BouncingScrollPhysics(),
          );
        }
      },
    );
  }
}
