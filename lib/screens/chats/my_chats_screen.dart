import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../../provider/providers.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../widgets/svg_picture.dart';
import '/screens/chats/conversation_screen.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button_without_icon.dart';
import '/auth/screens/location_screen.dart';
import '/utils/utils.dart';
import '../selling/seller_categories_list_screen.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseServices _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;
  late TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(
      length: 3,
      vsync: this,
    );
  }

  void onSellButtonClicked() async {
    final userData = await _services.getCurrentUserData();
    if (userData['location'] != null) {
      Get.to(
        () => const SellerCategoriesListScreen(),
      );
    } else {
      Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
      showSnackBar(
        content: 'Please set your location to sell products',
        color: redColor,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    tabBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mainProv = Provider.of<AppNavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Inbox',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
        bottom: TabBar(
          controller: tabBarController,
          indicatorColor: blueColor,
          indicatorWeight: 3,
          splashFactory: InkRipple.splashFactory,
          splashBorderRadius: BorderRadius.circular(10),
          labelStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: blueColor,
          unselectedLabelColor: lightBlackColor,
          tabs: const [
            Tab(child: Text('All')),
            Tab(child: Text('Buying')),
            Tab(child: Text('Selling')),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabBarController,
        physics: const BouncingScrollPhysics(),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _services.chats
                .where('users', arrayContains: _services.user!.uid)
                .orderBy('lastChatTime', descending: true)
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
                      'Something has gone wrong. Please try again',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data!.size == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: size.height * 0.3,
                      width: size.width,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: greyColor,
                      ),
                      child: const SVGPictureWidget(
                        url:
                            'https://res.cloudinary.com/bechdeapp/image/upload/v1674460521/illustrations/empty-message_z6lwtu.svg',
                        fit: BoxFit.contain,
                        semanticsLabel: 'Empty messages image',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'You have got no messages!',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'When you chat with a seller, it will show here',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          color: lightBlackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: CustomButtonWithoutIcon(
                        text: 'Explore Products',
                        onPressed: () => setState(() {
                          mainProv.switchToPage(0);
                        }),
                        bgColor: blueColor,
                        borderColor: blueColor,
                        textIconColor: whiteColor,
                      ),
                    ),
                  ],
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
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: fadedColor,
                    height: 0,
                    indent: 80,
                  );
                },
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return ChatCard(chatData: data);
                },
                itemCount: snapshot.data!.docs.length,
                physics: const ClampingScrollPhysics(),
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
                      'Something has gone wrong. Please try again',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data!.size == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: size.height * 0.3,
                      width: size.width,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: greyColor,
                      ),
                      child: const SVGPictureWidget(
                        url:
                            'https://res.cloudinary.com/bechdeapp/image/upload/v1674460521/illustrations/empty-message_z6lwtu.svg',
                        fit: BoxFit.contain,
                        semanticsLabel: 'Empty messages image',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'You have got no messages!',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'When you chat with a seller, it will show here',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          color: lightBlackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: CustomButtonWithoutIcon(
                        text: 'Explore Products',
                        onPressed: () => setState(() {
                          mainProv.switchToPage(0);
                        }),
                        bgColor: blueColor,
                        borderColor: blueColor,
                        textIconColor: whiteColor,
                      ),
                    ),
                  ],
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
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: fadedColor,
                    height: 0,
                    indent: 80,
                  );
                },
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return ChatCard(chatData: data);
                },
                itemCount: snapshot.data!.docs.length,
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
                      'Something has gone wrong. Please try again',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data!.size == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: size.height * 0.3,
                      width: size.width,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: greyColor,
                      ),
                      child: const SVGPictureWidget(
                        url:
                            'https://res.cloudinary.com/bechdeapp/image/upload/v1674460521/illustrations/empty-message_z6lwtu.svg',
                        fit: BoxFit.contain,
                        semanticsLabel: 'Empty messages image',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'You have got no messages!',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'When someone sends you a message, it will show here',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          color: lightBlackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
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
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: fadedColor,
                    height: 0,
                    indent: 80,
                  );
                },
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return ChatCard(chatData: data);
                },
                itemCount: snapshot.data!.docs.length,
              );
            },
          ),
        ],
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
  String prodId = '';
  String prodTitle = '';
  String productImage = '';
  String buyerName = '';
  String buyerProfileImage = '';
  String sellerName = '';
  String sellerUid = '';
  String sellerProfileImage = '';
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    final product = await _services
        .getProductDetails(widget.chatData['product']['productId']);
    final seller = await _services.getUserData(widget.chatData['users'][0]);
    final buyer = await _services.getUserData(widget.chatData['users'][1]);

    if (mounted) {
      setState(() {
        prodId = product.id;
        prodTitle = product['title'];
        isActive = product['isActive'];
        productImage = product['images'][0];
        sellerProfileImage = seller['profileImage'] ?? '';
        sellerUid = seller['uid'];
        sellerName = seller['name'] ?? '';
        buyerName = buyer['name'] ?? '';
        buyerProfileImage = buyer['profileImage'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Opacity(
      opacity: isActive == false ? 0.5 : 1,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        splashColor: transparentColor,
        onTap: () => Get.to(
          () => ConversationScreen(
            chatRoomId: widget.chatData['chatRoomId'],
            prodId: prodId,
            sellerId: sellerUid,
            users: widget.chatData['users'],
            makeOffer: false,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: size.width * 0.13,
                        height: size.width * 0.13,
                        padding: const EdgeInsets.only(right: 3, bottom: 3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: productImage,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            memCacheHeight: (size.width * 0.13).round(),
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Ionicons.alert_circle_outline,
                                size: 20,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Icon(
                                Ionicons.image,
                                size: 20,
                                color: lightBlackColor,
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: widget.chatData['users'][0] !=
                                  _services.user!.uid
                              ? sellerProfileImage == ''
                                  ? Container(
                                      width: size.width * 0.06,
                                      height: size.width * 0.06,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: blueColor,
                                      ),
                                      child: const Icon(
                                        Ionicons.person_outline,
                                        color: whiteColor,
                                        size: 20,
                                      ),
                                    )
                                  : SizedBox(
                                      width: size.width * 0.06,
                                      height: size.width * 0.06,
                                      child: CachedNetworkImage(
                                        imageUrl: sellerProfileImage,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        memCacheHeight:
                                            (size.width * 0.06).round(),
                                        memCacheWidth:
                                            (size.width * 0.06).round(),
                                        errorWidget: (context, url, error) {
                                          return const Icon(
                                            Ionicons.alert_circle_outline,
                                            size: 20,
                                            color: redColor,
                                          );
                                        },
                                        placeholder: (context, url) {
                                          return const Icon(
                                            Ionicons.image,
                                            size: 20,
                                            color: lightBlackColor,
                                          );
                                        },
                                      ),
                                    )
                              : buyerProfileImage == ''
                                  ? Container(
                                      width: size.width * 0.06,
                                      height: size.width * 0.06,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: blueColor,
                                      ),
                                      child: const Icon(
                                        Ionicons.person_outline,
                                        color: whiteColor,
                                        size: 20,
                                      ),
                                    )
                                  : SizedBox(
                                      width: size.width * 0.06,
                                      height: size.width * 0.06,
                                      child: CachedNetworkImage(
                                        imageUrl: buyerProfileImage,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        memCacheHeight:
                                            (size.width * 0.06).round(),
                                        memCacheWidth:
                                            (size.width * 0.06).round(),
                                        errorWidget: (context, url, error) {
                                          return const Icon(
                                            Ionicons.alert_circle_outline,
                                            size: 20,
                                            color: redColor,
                                          );
                                        },
                                        placeholder: (context, url) {
                                          return const Icon(
                                            Ionicons.image,
                                            size: 20,
                                            color: lightBlackColor,
                                          );
                                        },
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          widget.chatData['users'][0] == _services.user!.uid
                              ? Text(
                                  buyerName == '' ? 'BechDe User' : buyerName,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                    color: blackColor,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                )
                              : Text(
                                  sellerName == '' ? 'BechDe User' : sellerName,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                    color: blackColor,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            prodTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.interTight(
                              fontWeight: FontWeight.w500,
                              color: blackColor,
                              fontSize: 13,
                            ),
                          ),
                          if (widget.chatData['lastChat'] != null)
                            Column(
                              children: [
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  widget.chatData['lastChat'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: widget.chatData['read'] == false
                                      ? GoogleFonts.interTight(
                                          fontWeight: FontWeight.w700,
                                          color: blueColor,
                                          fontSize: 13,
                                        )
                                      : GoogleFonts.interTight(
                                          fontWeight: FontWeight.w500,
                                          color: blackColor,
                                          fontSize: 13,
                                        ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isActive == false)
                Text(
                  'Product is currently unavailable. Chat is disabled.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w500,
                    color: redColor,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
