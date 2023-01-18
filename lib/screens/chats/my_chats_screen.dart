import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:provider/provider.dart';

import '../../widgets/svg_picture.dart';
import '/provider/main_provider.dart';
import '/screens/chats/conversation_screen.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button_without_icon.dart';
import '/auth/screens/email_verification_screen.dart';
import '/auth/screens/location_screen.dart';
import '/utils/utils.dart';
import '../selling/seller_categories_list_screen.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final FirebaseServices _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;

  onSellButtonClicked() {
    _services.getCurrentUserData().then((value) {
      if (value['location'] != null) {
        Get.to(
          () => const SellerCategoriesListScreen(),
        );
        return;
      }
      Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
      showSnackBar(
        content: 'Please set your location to sell products',
        color: redColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mainProv = Provider.of<MainProvider>(context, listen: false);

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: whiteColor,
          elevation: 0.2,
          iconTheme: const IconThemeData(color: blackColor),
          centerTitle: true,
          title: const Text(
            'Inbox',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 15,
            ),
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: blueColor,
            indicatorWeight: 3,
            splashBorderRadius: BorderRadius.circular(10),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'Rubik',
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              fontFamily: 'Rubik',
            ),
            labelColor: blackColor,
            unselectedLabelColor: lightBlackColor,
            tabs: const [
              Tab(child: Text('All')),
              Tab(child: Text('Buying')),
              Tab(child: Text('Selling')),
            ],
          ),
        ),
        body: TabBarView(
          physics: const ClampingScrollPhysics(),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Something has gone wrong. Please try again',
                        style: TextStyle(
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
                              'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fempty-message.svg?alt=media&token=affb948b-7d3f-4a69-aebe-df70e2e13d19',
                          fit: BoxFit.contain,
                          semanticsLabel: 'Empty messages image',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'You have got no messages!',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'When you chat with a seller, it will show here',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                      child: SpinKitFadingCircle(
                        color: lightBlackColor,
                        size: 30,
                        duration: Duration(milliseconds: 1000),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: fadedColor,
                      height: 0,
                      indent: 15,
                      endIndent: 15,
                    );
                  },
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Something has gone wrong. Please try again',
                        style: TextStyle(
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
                              'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fempty-message.svg?alt=media&token=affb948b-7d3f-4a69-aebe-df70e2e13d19',
                          fit: BoxFit.contain,
                          semanticsLabel: 'Empty messages image',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'You have got no messages!',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'When you chat with a seller, it will show here',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                      child: SpinKitFadingCircle(
                        color: lightBlackColor,
                        size: 30,
                        duration: Duration(milliseconds: 1000),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: fadedColor,
                      height: 0,
                      indent: 15,
                      endIndent: 15,
                    );
                  },
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Something has gone wrong. Please try again',
                        style: TextStyle(
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
                              'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fempty-message.svg?alt=media&token=affb948b-7d3f-4a69-aebe-df70e2e13d19',
                          fit: BoxFit.contain,
                          semanticsLabel: 'Empty messages image',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'You have got no messages!',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'When someone sends you a message, it will show here',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                          text: 'Start Selling',
                          onPressed: !user!.emailVerified &&
                                  user!.providerData[0].providerId == 'password'
                              ? () => Get.to(
                                    () => const EmailVerificationScreen(),
                                  )
                              : onSellButtonClicked,
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
                      child: SpinKitFadingCircle(
                        color: lightBlackColor,
                        size: 30,
                        duration: Duration(milliseconds: 1000),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: fadedColor,
                      height: 0,
                      indent: 15,
                      endIndent: 15,
                    );
                  },
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    return ChatCard(chatData: data);
                  },
                  itemCount: snapshot.data!.docs.length,
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
    getProductDetails();
    getSellerDetails();
    getBuyerDetails();
    super.initState();
  }

  getProductDetails() async {
    await _services
        .getProductDetails(widget.chatData['product']['productId'])
        .then((value) {
      if (mounted) {
        setState(() {
          prodId = value.id;
          prodTitle = value['title'];
          isActive = value['isActive'];
          productImage = value['images'][0];
        });
      }
    });
  }

  getSellerDetails() async {
    await _services.getUserData(widget.chatData['users'][0]).then((value) {
      if (mounted) {
        setState(() {
          value['profileImage'] == null
              ? sellerProfileImage = ''
              : sellerProfileImage = value['profileImage'];
          sellerUid = value['uid'];
          value['name'] == null ? sellerName = '' : sellerName = value['name'];
        });
      }
    });
  }

  getBuyerDetails() async {
    await _services.getUserData(widget.chatData['users'][1]).then((value) {
      if (mounted) {
        setState(() {
          value['name'] == null ? buyerName = '' : buyerName = value['name'];
          value['profileImage'] == null
              ? buyerProfileImage = ''
              : buyerProfileImage = value['profileImage'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Opacity(
      opacity: isActive == false ? 0.5 : 1,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        splashColor: fadedColor,
        onTap: () => Get.to(
          () => ConversationScreen(
            chatRoomId: widget.chatData['chatRoomId'],
            prodId: prodId,
            sellerId: sellerUid,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: widget.chatData['users'][0] != _services.user!.uid
                        ? sellerProfileImage == ''
                            ? Container(
                                width: size.width * 0.12,
                                height: size.width * 0.12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: blueColor,
                                ),
                                child: const Icon(
                                  Ionicons.person,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: sellerProfileImage,
                                width: size.width * 0.12,
                                height: size.width * 0.12,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    Ionicons.alert_circle,
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
                              )
                        : buyerProfileImage == ''
                            ? Container(
                                width: size.width * 0.12,
                                height: size.width * 0.12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: blueColor,
                                ),
                                child: const Icon(
                                  Ionicons.person,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: buyerProfileImage,
                                width: size.width * 0.12,
                                height: size.width * 0.12,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    Ionicons.alert_circle,
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
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.chatData['users'][0] == _services.user!.uid
                              ? RichText(
                                  text: TextSpan(
                                    text: buyerName == ''
                                        ? 'BechDe User •'
                                        : '$buyerName •',
                                    children: const [
                                      TextSpan(
                                        text: ' Buyer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: redColor,
                                        ),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: blackColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                )
                              : RichText(
                                  text: TextSpan(
                                    text: sellerName == ''
                                        ? 'BechDe User •'
                                        : '$sellerName •',
                                    children: const [
                                      TextSpan(
                                        text: ' Seller',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: blueColor,
                                        ),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: blackColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                          if (widget.chatData['lastChat'] != null)
                            Text(
                              widget.chatData['lastChat'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: widget.chatData['read'] == false
                                  ? const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: blueColor,
                                      fontSize: 14,
                                    )
                                  : const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: blackColor,
                                      fontSize: 14,
                                    ),
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: greyColor,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: size.width * 0.1,
                                  height: size.width * 0.1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: productImage,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                                        return const Icon(
                                          Ionicons.alert_circle,
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
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    prodTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: lightBlackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isActive == false)
                const Text(
                  'Product is currently unavailable. Chat is disabled.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
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
