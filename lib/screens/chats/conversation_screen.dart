import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '/utils/utils.dart';
import '/screens/product_details_screen.dart';
import '/screens/chats/chat_stream.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';

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
  final TextEditingController offerPriceController = TextEditingController();

  String sellerUid = '';
  String imageUrl = '';
  String title = '';
  int price = 0;
  bool isActive = true;
  late DocumentSnapshot prod;
  late DocumentSnapshot sellerData;
  bool isLoading = false;

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
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
    await _services.getUserData(widget.sellerId).then((value) {
      if (mounted) {
        setState(() {
          sellerData = value;
        });
      }
    });
    await _services.getProductDetails(widget.prodId).then((value) {
      if (mounted) {
        setState(() {
          prod = value;
          isActive = value['isActive'];
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  sendOfferMessage(String offer) async {
    Map<String, dynamic> message = {
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
              top: 15,
              right: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                const Text(
                  'Make an offer 💵',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
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
                  style: const TextStyle(
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
                    errorStyle: const TextStyle(
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
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: fadedColor,
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  icon: Ionicons.arrow_forward,
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
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                const Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
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
                  child: const Text(
                    'Are you sure you want to delete this chat? This action cannot be reversed.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
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
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'No, Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showOptionsDialog() {
    showModalBottomSheet(
      context: context,
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
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
                CustomButton(
                  icon: Ionicons.trash_bin,
                  text: 'Delete Chat',
                  onPressed: () {
                    Get.back();
                    showDeleteDialog();
                  },
                  bgColor: whiteColor,
                  borderColor: redColor,
                  textIconColor: redColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButtonWithoutIcon(
                  text: 'Cancel',
                  onPressed: () => Get.back(),
                  bgColor: whiteColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  sendMessage(String text) async {
    Map<String, dynamic> message = {
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
  }

  @override
  void dispose() {
    offerPriceController.dispose();
    chatMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        actions: [
          GestureDetector(
            onTap: showOptionsDialog,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Ionicons.ellipsis_horizontal,
              color: blackColor,
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
        title: sellerUid == _services.user!.uid
            ? const Text(
                'Chat with buyer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 15,
                ),
              )
            : const Text(
                'Chat with seller',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
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
                child: SpinKitFadingCircle(
                  color: lightBlackColor,
                  size: 30,
                  duration: Duration(milliseconds: 1000),
                ),
              ),
            )
          : Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.to(
                    () => ProductDetailsScreen(
                      productData: prod,
                      sellerData: sellerData,
                    ),
                  ),
                  child: Container(
                    color: blueColor,
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.20,
                          height: MediaQuery.of(context).size.width * 0.20,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return const Icon(
                                    Ionicons.alert_circle,
                                    size: 15,
                                    color: redColor,
                                  );
                                },
                                placeholder: (context, url) {
                                  return const Icon(
                                    Ionicons.image,
                                    size: 15,
                                    color: lightBlackColor,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: whiteColor,
                                ),
                              ),
                              Text(
                                priceFormat.format(price),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: whiteColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ChatStream(chatRoomId: widget.chatRoomId),
                ),
                if (isActive == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Wrap(
                      runSpacing: 0,
                      spacing: 5,
                      alignment: WrapAlignment.start,
                      children: [
                        if (sellerUid != _services.user!.uid)
                          ActionChip(
                            pressElevation: 5,
                            label: const Text('Make offer'),
                            backgroundColor: Colors.green,
                            labelStyle: const TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                            onPressed: showMakeOfferDialog,
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Is it available?'),
                          backgroundColor: greyColor,
                          labelStyle: const TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Is it available?'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Hello'),
                          backgroundColor: greyColor,
                          labelStyle: const TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Hello'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Please reply'),
                          backgroundColor: greyColor,
                          labelStyle: const TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Please reply'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        ActionChip(
                          pressElevation: 5,
                          label: const Text('Not interested'),
                          backgroundColor: greyColor,
                          labelStyle: const TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => sendMessage('Not interested'),
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                isActive == false
                    ? Container(
                        color: redColor,
                        height: 80,
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: Text(
                            'This product is currently unavailable.',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
                                hint: 'Write something',
                                maxLength: 500,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (chatMessageController.text.isNotEmpty) {
                                    sendMessage(chatMessageController.text);
                                  }
                                },
                                tooltip: 'Send message',
                                backgroundColor: blueColor,
                                elevation: 0,
                                highlightElevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Ionicons.send,
                                  size: 25,
                                  color: whiteColor,
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
