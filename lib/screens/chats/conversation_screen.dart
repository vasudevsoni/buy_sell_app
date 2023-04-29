import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/community_guidelines_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../widgets/custom_loading_indicator.dart';
import '/utils/utils.dart';
import '/screens/product_details_screen.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String prodId;
  final String sellerId;
  final bool makeOffer;
  const ConversationScreen({
    super.key,
    required this.chatRoomId,
    required this.prodId,
    required this.sellerId,
    required this.makeOffer,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final FirebaseServices _services = FirebaseServices();
  final ScrollController scrollController = ScrollController();
  final TextEditingController chatMessageController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();

  String sellerUid = '';
  String imageUrl = '';
  String title = '';
  String name = '';
  bool isActive = true;
  late DocumentSnapshot prod;
  late DocumentSnapshot sellerData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getDetails(makeOffer: widget.makeOffer);
  }

  scrollDown() {
    final double end = scrollController.position.maxScrollExtent;
    if (scrollController.hasClients) {
      scrollController.animateTo(
        end,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }
  }

  getDetails({makeOffer}) async {
    setState(() {
      isLoading = true;
    });
    final chatRoom = await _services.chats.doc(widget.chatRoomId).get();
    if (mounted) {
      setState(() {
        sellerUid = chatRoom['users'][0];
        title = chatRoom['product']['title'];
        imageUrl = chatRoom['product']['productImage'];
      });
    }

    final seller = await _services.getUserData(widget.sellerId);
    if (mounted) {
      setState(() {
        sellerData = seller;
        name = seller['name'];
      });
    }

    final product = await _services.getProductDetails(widget.prodId);
    if (mounted) {
      setState(() {
        prod = product;
        isActive = product['isActive'];
      });
    }

    setState(() {
      isLoading = false;
    });

    if (widget.makeOffer == true) {
      showMakeOfferDialog();
    }
  }

  sendOfferMessage(String offer) async {
    final Map<String, dynamic> message = {
      'message': offer,
      'sentBy': _services.user!.uid,
      'time': DateTime.now().microsecondsSinceEpoch,
      'isOffer': true,
    };
    await _services.sendChat(
      chatRoomId: widget.chatRoomId,
      message: message,
    );
    offerPriceController.clear();
    scrollDown();
  }

  showMakeOfferDialog() {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: transparentColor,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: whiteColor,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 15,
              left: 15,
              top: 5,
              right: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: fadedColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    'Make an offer 💵',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: offerPriceController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter a price you want to pay',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    counterText: '',
                    fillColor: greyColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: transparentColor,
                        width: 0,
                        strokeAlign: StrokeAlign.inside,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: transparentColor,
                        width: 0,
                        strokeAlign: StrokeAlign.inside,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: redColor,
                        width: 1.5,
                        strokeAlign: StrokeAlign.inside,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    errorStyle: GoogleFonts.interTight(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: redColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: blueColor,
                        width: 1.5,
                        strokeAlign: StrokeAlign.inside,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: blueColor,
                        width: 1.5,
                        strokeAlign: StrokeAlign.inside,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintStyle: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: fadedColor,
                    ),
                    labelStyle: GoogleFonts.interTight(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Good offer: Rs.${(prod['price'] * 85) / 100} - Rs.${(prod['price'] * 95) / 100}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: blueColor,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        bgColor: whiteColor,
                        borderColor: greyColor,
                        textIconColor: blackColor,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: CustomButton(
                        icon: MdiIcons.arrowRight,
                        text: 'Send Offer',
                        onPressed: () {
                          if (offerPriceController.text.isEmpty) {
                            return;
                          }
                          final offerPrice = priceFormat
                              .format(int.parse(offerPriceController.text));
                          sendOfferMessage(
                              'I would like to buy this for $offerPrice');
                          Get.back();
                        },
                        bgColor: blueColor,
                        borderColor: blueColor,
                        textIconColor: whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showDeleteDialog() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: transparentColor,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: whiteColor,
            ),
            padding: const EdgeInsets.only(
              left: 15,
              top: 5,
              right: 15,
              bottom: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: fadedColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    'Are you sure?',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greyColor,
                  ),
                  child: Text(
                    'Are you sure you want to delete this chat? This action cannot be reversed.',
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'No, Cancel',
                        onPressed: () => Get.back(),
                        bgColor: whiteColor,
                        borderColor: greyColor,
                        textIconColor: blackColor,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: CustomButtonWithoutIcon(
                        text: 'Yes, Delete',
                        onPressed: () {
                          _services.deleteChat(
                            chatRoomId: widget.chatRoomId,
                          );
                          Get.back();
                          Get.back();
                        },
                        bgColor: whiteColor,
                        borderColor: redColor,
                        textIconColor: redColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  sendMessage(String text) async {
    final Map<String, dynamic> message = {
      'message': text,
      'sentBy': _services.user!.uid,
      'time': DateTime.now().microsecondsSinceEpoch,
      'isOffer': false,
    };
    chatMessageController.clear();
    await _services.sendChat(
      chatRoomId: widget.chatRoomId,
      message: message,
    );
    scrollDown();
  }

  @override
  void dispose() {
    offerPriceController.dispose();
    chatMessageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        actions: [
          GestureDetector(
            onTap: showDeleteDialog,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              MdiIcons.deleteOutline,
              color: redColor,
              size: 25,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: isLoading
          ? const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            )
          : Column(
              children: [
                if (!isKeyboard)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.to(
                      () => ProductDetailsScreen(
                        productData: prod,
                      ),
                    ),
                    child: Container(
                      color: blackColor,
                      child: Row(
                        children: [
                          SizedBox(
                            width: size.width * 0.15,
                            height: size.width * 0.15,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  memCacheHeight: (size.height * 0.15).round(),
                                  errorWidget: (context, url, error) {
                                    return const Icon(
                                      MdiIcons.alertDecagramOutline,
                                      size: 15,
                                      color: redColor,
                                    );
                                  },
                                  placeholder: (context, url) {
                                    return const Icon(
                                      MdiIcons.imageFilterHdr,
                                      size: 15,
                                      color: lightBlackColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => Get.to(
                    () => const CommunityGuidelinesScreen(),
                  ),
                  child: Container(
                    width: size.width,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: blueColor,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          AutoSizeText(
                            'Stay safe! Please read community guidelines',
                            style: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            MdiIcons.arrowRight,
                            color: whiteColor,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _services.chats
                        .doc(widget.chatRoomId)
                        .collection('messages')
                        .orderBy('time')
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'No messages here yet!',
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
                            Text(
                              'Start by sending a Hi',
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: lightBlackColor,
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
                          return const SizedBox(
                            height: 2,
                          );
                        },
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        itemBuilder: (context, index) {
                          final date = DateFormat.yMMMd().format(
                            DateTime.fromMicrosecondsSinceEpoch(
                              snapshot.data!.docs[index]['time'],
                            ),
                          );
                          final time = DateFormat.jm().format(
                            DateTime.fromMicrosecondsSinceEpoch(
                              snapshot.data!.docs[index]['time'],
                            ),
                          );
                          final String sentBy =
                              snapshot.data!.docs[index]['sentBy'];
                          final String me = _services.user!.uid;
                          return Column(
                            children: [
                              snapshot.data!.docs[index]['isOffer'] == true
                                  ? Align(
                                      alignment: sentBy == me
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 5,
                                          bottom: 2,
                                        ),
                                        constraints: BoxConstraints(
                                            maxWidth: size.width * 0.75),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: greenColor,
                                          borderRadius: sentBy == me
                                              ? const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(3),
                                                )
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(3),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                        ),
                                        child: Text(
                                          snapshot.data!.docs[index]['message'],
                                          style: GoogleFonts.interTight(
                                            color: whiteColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Align(
                                      alignment: sentBy == me
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 5,
                                          bottom: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        constraints: BoxConstraints(
                                            maxWidth: size.width * 0.75),
                                        decoration: BoxDecoration(
                                          color: sentBy == me
                                              ? blueColor
                                              : greyColor,
                                          borderRadius: sentBy == me
                                              ? const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(3),
                                                )
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(3),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                        ),
                                        child: Text(
                                          snapshot.data!.docs[index]['message'],
                                          style: GoogleFonts.interTight(
                                            color: sentBy == me
                                                ? whiteColor
                                                : blackColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                              Align(
                                alignment: sentBy == me
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment: sentBy == me
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          time,
                                          style: GoogleFonts.interTight(
                                            color: blackColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          date,
                                          style: GoogleFonts.interTight(
                                            color: fadedColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          );
                        },
                        itemCount: snapshot.data!.docs.length,
                      );
                    },
                  ),
                ),
                if (isActive == true)
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    height: 50,
                    width: size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (sellerUid != _services.user!.uid &&
                            prod['catName'] != 'Jobs')
                          Row(
                            children: [
                              ActionChip(
                                pressElevation: 5,
                                label: const Text('Make an offer'),
                                backgroundColor: greenColor,
                                labelStyle: GoogleFonts.interTight(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                onPressed: showMakeOfferDialog,
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Is it available?'),
                          backgroundColor: greyColor,
                          labelStyle: GoogleFonts.interTight(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Is it available?'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Hello'),
                          backgroundColor: greyColor,
                          labelStyle: GoogleFonts.interTight(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Hello'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Please reply'),
                          backgroundColor: greyColor,
                          labelStyle: GoogleFonts.interTight(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Please reply'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Not interested'),
                          backgroundColor: greyColor,
                          labelStyle: GoogleFonts.interTight(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Not interested'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Let\'s meet'),
                          backgroundColor: greyColor,
                          labelStyle: GoogleFonts.interTight(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Let\'s meet'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                isActive == false
                    ? Container(
                        color: redColor,
                        height: 80,
                        padding: const EdgeInsets.all(15),
                        width: size.width,
                        child: Center(
                          child: Text(
                            'This listing is currently unavailable.',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 15,
                          top: 5,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: chatMessageController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.send,
                                hint: 'Chat here...',
                                maxLength: 500,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Tooltip(
                              message: 'Send message',
                              child: GestureDetector(
                                onTap: () {
                                  if (chatMessageController.text.isNotEmpty) {
                                    sendMessage(chatMessageController.text);
                                  }
                                },
                                child: const Icon(
                                  MdiIcons.send,
                                  size: 25,
                                  color: blueColor,
                                ),
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
