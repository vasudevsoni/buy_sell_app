import 'dart:ui';

import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/popup_menu_model.dart';
import '../../utils/utils.dart';
import '../../screens/chats/chat_stream.dart';
import '../../services/firebase_services.dart';
import '../../widgets/custom_button_without_icon.dart';
import '../../widgets/custom_text_field.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String prodId;
  final String sellerId;
  const ConversationScreen({
    super.key,
    required this.chatRoomId,
    required this.prodId,
    required this.sellerId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final FirebaseServices _services = FirebaseServices();
  final TextEditingController chatMessageController = TextEditingController();
  final CustomPopupMenuController popupMenucontroller =
      CustomPopupMenuController();
  String sellerUid = '';
  String imageUrl = '';
  String title = '';
  int price = 0;
  late DocumentSnapshot prod;
  late DocumentSnapshot sellerData;

  @override
  void initState() {
    getAllDetails();
    super.initState();
  }

  getAllDetails() async {
    await _services.chats.doc(widget.chatRoomId).get().then((value) {
      if (mounted) {
        setState(() {
          sellerUid = value['users'][0];
          title = value['product']['title'];
          price = value['product']['price'];
          imageUrl = value['product']['productImage'];
        });
      }
    });
    await _services.getProductDetails(widget.prodId).then((value) {
      if (mounted) {
        prod = value;
      }
    });
    await _services.getUserData(widget.sellerId).then((value) {
      if (mounted) {
        sellerData = value;
      }
    });
  }

  sendMessage() {
    if (chatMessageController.text.isNotEmpty) {
      Map<String, dynamic> message = {
        'message': chatMessageController.text,
        'sentBy': _services.user!.uid,
        'time': DateTime.now().microsecondsSinceEpoch,
      };
      _services.createChat(
        chatRoomId: widget.chatRoomId,
        context: context,
        message: message,
      );
      chatMessageController.clear();
    }
  }

  @override
  void dispose() {
    popupMenucontroller.dispose();
    chatMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );
    List<PopupMenuModel> menuItems = [
      PopupMenuModel('Delete Chat', Iconsax.message_remove4),
    ];
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        actions: [
          CustomPopupMenu(
            arrowColor: Colors.white,
            menuBuilder: () => ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: Colors.white,
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: menuItems
                        .map(
                          (item) => InkWell(
                            onTap: () {
                              if (item.title == 'Delete Chat') {
                                popupMenucontroller.hideMenu();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Are you sure?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          color: greyColor,
                                        ),
                                        child: Text(
                                          'Your chat with this person will be deleted. This action cannot be reversed.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      actionsPadding: const EdgeInsets.all(15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      titlePadding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 15,
                                        bottom: 10,
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        bottom: 5,
                                        top: 5,
                                      ),
                                      actions: [
                                        CustomButtonWithoutIcon(
                                          text: 'Yes, Delete Chat',
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _services
                                                .deleteChat(widget.chatRoomId);
                                            Navigator.of(context).pushNamed(
                                                MainScreen.routeName);
                                            showSnackBar(
                                              context: context,
                                              content: 'Chat deleted',
                                              color: redColor,
                                            );
                                          },
                                          bgColor: redColor,
                                          borderColor: redColor,
                                          textIconColor: Colors.white,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomButtonWithoutIcon(
                                          text: 'No, Cancel',
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          bgColor: Colors.white,
                                          borderColor: blackColor,
                                          textIconColor: blackColor,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        item.title,
                                        style: GoogleFonts.poppins(
                                          color: blackColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    item.icon,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            pressType: PressType.singleClick,
            verticalMargin: -10,
            controller: popupMenucontroller,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: const Icon(
                Iconsax.more4,
                color: blackColor,
                size: 15,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: sellerUid == _services.user!.uid
            ? Text(
                'Chat with buyer',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                ),
              )
            : Text(
                'Chat with seller',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
      ),
      body: Column(
        children: [
          Container(
            color: blueColor,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  PageTransition(
                    child: ProductDetailsScreen(
                      productData: prod,
                      sellerData: sellerData,
                    ),
                    type: PageTransitionType.rightToLeftWithFade,
                  ),
                );
              },
              leading: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return const Icon(
                        Iconsax.warning_24,
                        size: 15,
                        color: redColor,
                      );
                    },
                    placeholder: (context, url) {
                      return const Icon(
                        Iconsax.image4,
                        size: 15,
                        color: lightBlackColor,
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                title,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                priceFormat.format(price),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: greyColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: ChatStream(chatRoomId: widget.chatRoomId),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Text(
              'Never share confidential information like passwords, card details, bank details etc.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: lightBlackColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 15,
              top: 5,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: CustomTextField(
                    controller: chatMessageController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    label: 'Send a message',
                    hint: 'Ask for product details, features and more',
                    maxLength: 500,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Iconsax.send_14,
                      size: 25,
                    ),
                    color: blueColor,
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
