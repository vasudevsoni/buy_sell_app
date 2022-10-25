import 'package:buy_sell_app/screens/chats/conversation_screen.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';

import '../../utils/utils.dart';

class MyChatsScreen extends StatefulWidget {
  static const String routeName = '/my-chats-screen';
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0.2,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            'My Chats',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          bottom: TabBar(
            indicatorColor: blueColor,
            indicatorWeight: 4,
            isScrollable: false,
            tabs: [
              Tab(
                child: Text(
                  'All',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Buying',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Selling',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _services.chats
                  .where('users', arrayContains: _services.user!.uid)
                  .snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
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
                } else if (snapshot.hasData && snapshot.data!.size == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        'Your chats will show here',
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
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ChatCard(
                      chatData: data,
                    );
                  }).toList(),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _services.chats
                  .where('users', arrayContains: _services.user!.uid)
                  .where('product.seller', isNotEqualTo: _services.user!.uid)
                  .snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
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
                } else if (snapshot.hasData && snapshot.data!.size == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        'Your buying chats will show here',
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
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ChatCard(
                      chatData: data,
                    );
                  }).toList(),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _services.chats
                  .where('users', arrayContains: _services.user!.uid)
                  .where('product.seller', isEqualTo: _services.user!.uid)
                  .snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
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
                } else if (snapshot.hasData && snapshot.data!.size == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        'Your selling chats will show here',
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
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ChatCard(
                      chatData: data,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatCard extends StatefulWidget {
  final Map<String, dynamic> chatData;
  const ChatCard({
    super.key,
    required this.chatData,
  });

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final FirebaseServices _services = FirebaseServices();
  DocumentSnapshot? doc;
  DocumentSnapshot? sellerDetails;
  DocumentSnapshot? buyerDetails;

  @override
  void initState() {
    getProductDetails();
    getSellerDetails();
    getBuyerDetails();
    super.initState();
  }

  getProductDetails() async {
    await _services
        .getProductDetails(widget.chatData['product']['productId'].toString())
        .then((value) {
      if (mounted) {
        setState(() {
          doc = value;
        });
      }
    });
  }

  getSellerDetails() async {
    await _services.getUserData(widget.chatData['users'][0]).then((value) {
      if (mounted) {
        setState(() {
          sellerDetails = value;
        });
      }
    });
  }

  getBuyerDetails() async {
    await _services.getUserData(widget.chatData['users'][1]).then((value) {
      if (mounted) {
        setState(() {
          buyerDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return doc == null
        ? Container()
        : Column(
            children: [
              InkWell(
                onTap: () {
                  _services.chats.doc(widget.chatData['chatRoomId']).update({
                    'read': true,
                  });
                  Navigator.of(context).push(
                    PageTransition(
                      child: ConversationScreen(
                        chatRoomId: widget.chatData['chatRoomId'],
                        prodId: doc!.id,
                        sellerId: doc!['sellerUid'],
                      ),
                      type: PageTransitionType.rightToLeftWithFade,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 15,
                    right: 15,
                    bottom: 5,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: widget.chatData['users'][0] !=
                                _services.user!.uid
                            ? sellerDetails!['profileImage'] == null
                                ? Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    height: MediaQuery.of(context).size.width *
                                        0.12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: blueColor,
                                    ),
                                    child: const Icon(
                                      Iconsax.security_user4,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: sellerDetails!['profileImage'],
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    height: MediaQuery.of(context).size.width *
                                        0.12,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return const Icon(
                                        Iconsax.warning_24,
                                        size: 20,
                                        color: redColor,
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return const Icon(
                                        Iconsax.image4,
                                        size: 20,
                                        color: lightBlackColor,
                                      );
                                    },
                                  )
                            : buyerDetails!['profileImage'] == null
                                ? Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    height: MediaQuery.of(context).size.width *
                                        0.12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: blueColor,
                                    ),
                                    child: const Icon(
                                      Iconsax.security_user4,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl:
                                        buyerDetails!['profileImage'] ?? '',
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    height: MediaQuery.of(context).size.width *
                                        0.12,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return const Icon(
                                        Iconsax.warning_24,
                                        size: 20,
                                        color: redColor,
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return const Icon(
                                        Iconsax.image4,
                                        size: 20,
                                        color: lightBlackColor,
                                      );
                                    },
                                  ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding: const EdgeInsets.only(
                          left: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.chatData['users'][0] == _services.user!.uid
                                ? Text(
                                    buyerDetails!['name'] ??
                                        'Name not disclosed',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  )
                                : Text(
                                    sellerDetails!['name'] ??
                                        'Name not disclosed',
                                    maxLines: 13,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                            if (widget.chatData['lastChat'] != null)
                              Text(
                                widget.chatData['lastChat'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: widget.chatData['read'] == false
                                    ? GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: blueColor,
                                        fontSize: 12,
                                      )
                                    : GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
                                        fontSize: 12,
                                      ),
                              ),
                            Text(
                              doc!['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                color: fadedColor,
                                fontSize: 12,
                              ),
                            ),
                            widget.chatData['users'][0] == _services.user!.uid
                                ? Chip(
                                    label: Text(
                                      'Buyer',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: redColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    backgroundColor: greyColor,
                                  )
                                : Chip(
                                    label: Text(
                                      'Seller',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: blueColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    backgroundColor: greyColor,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 0,
                color: fadedColor,
                indent: 15,
                endIndent: 15,
              ),
            ],
          );
  }
}
