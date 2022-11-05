import 'package:animations/animations.dart';
import 'package:buy_sell_app/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../utils/utils.dart';
import '../../screens/chats/chat_stream.dart';
import '../../services/firebase_services.dart';
import '../../widgets/custom_button.dart';
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
  final TextEditingController offerPriceController = TextEditingController();

  String sellerUid = '';
  String imageUrl = '';
  String title = '';
  int price = 0;
  bool isActive = true;
  late DocumentSnapshot prod;
  late DocumentSnapshot sellerData;

  var priceFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '₹',
    name: '',
  );

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
        setState(() {
          prod = value;
          isActive = value['isActive'];
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
      context: context,
      message: message,
    );
    offerPriceController.clear();
  }

  showMakeOfferDialog() {
    showModal(
      configuration: const FadeScaleTransitionConfiguration(),
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Make an offer 💵',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          content: TextFormField(
            controller: offerPriceController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: 'Offer price*',
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
                  color: Colors.transparent,
                  width: 0,
                  strokeAlign: StrokeAlign.inside,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 0,
                  strokeAlign: StrokeAlign.inside,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                  strokeAlign: StrokeAlign.inside,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              errorStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
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
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: greyColor,
              ),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              floatingLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: lightBlackColor,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
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
            CustomButton(
              icon: FontAwesomeIcons.arrowRight,
              text: 'Send offer',
              onPressed: () {
                if (offerPriceController.text.isNotEmpty) {
                  final offerPrice =
                      priceFormat.format(int.parse(offerPriceController.text));
                  sendOfferMessage('I would like to buy this for $offerPrice');
                  Get.back();
                }
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
              onPressed: () {
                Get.back();
              },
              bgColor: whiteColor,
              borderColor: greyColor,
              textIconColor: blackColor,
            ),
          ],
        );
      },
    );
  }

  showOptionsDialog() {
    showModal(
      configuration: const FadeScaleTransitionConfiguration(),
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          actions: [
            CustomButton(
              icon: FontAwesomeIcons.trash,
              text: 'Delete chat',
              onPressed: () {
                _services.deleteChat(
                    chatRoomId: widget.chatRoomId, context: context);
                Get.back();
                Get.back();
              },
              bgColor: redColor,
              borderColor: redColor,
              textIconColor: whiteColor,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButtonWithoutIcon(
              text: 'Cancel',
              onPressed: () {
                Get.back();
              },
              bgColor: whiteColor,
              borderColor: greyColor,
              textIconColor: blackColor,
            ),
          ],
        );
      },
    );
  }

  sendMessage() async {
    if (chatMessageController.text.isNotEmpty) {
      Map<String, dynamic> message = {
        'message': chatMessageController.text,
        'sentBy': _services.user!.uid,
        'time': DateTime.now().microsecondsSinceEpoch,
        'isOffer': false,
      };
      chatMessageController.clear();
      await _services.sendChat(
        chatRoomId: widget.chatRoomId,
        context: context,
        message: message,
      );
    }
  }

  @override
  void dispose() {
    offerPriceController.dispose();
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

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.5,
        actions: [
          GestureDetector(
            onTap: showOptionsDialog,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              FontAwesomeIcons.ellipsis,
              color: blackColor,
              size: 20,
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
            ? Text(
                'Chat with buyer',
                style: GoogleFonts.poppins(
                  color: blackColor,
                  fontSize: 15,
                ),
              )
            : Text(
                'Chat with seller',
                style: GoogleFonts.poppins(
                  color: blackColor,
                  fontSize: 15,
                ),
              ),
      ),
      body: Column(
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              lightSource: LightSource.top,
              shape: NeumorphicShape.convex,
              depth: 0,
              intensity: 0,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(0),
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.to(() => ProductDetailsScreen(
                      productData: prod,
                      sellerData: sellerData,
                    ));
              },
              child: Container(
                color: blueColor,
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.22,
                      height: MediaQuery.of(context).size.width * 0.22,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return const Icon(
                                FontAwesomeIcons.circleExclamation,
                                size: 15,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Icon(
                                FontAwesomeIcons.solidImage,
                                size: 15,
                                color: lightBlackColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: whiteColor,
                            ),
                          ),
                          Text(
                            priceFormat.format(price),
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
          ),
          Expanded(
            child: ChatStream(chatRoomId: widget.chatRoomId),
          ),
          if (isActive == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                'Note - Never share confidential information like passwords, card details, bank details etc.',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: lightBlackColor,
                ),
              ),
            ),
          isActive == false
              ? Container(
                  color: redColor,
                  height: 80,
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      'This item is currently unavailable.',
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
                          label: 'Write something',
                          hint: 'Ask for product details, features and more',
                          maxLength: 500,
                        ),
                      ),
                      if (sellerUid != _services.user!.uid)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: NeumorphicFloatingActionButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              showMakeOfferDialog();
                            },
                            tooltip: 'Make an offer',
                            style: NeumorphicStyle(
                              lightSource: LightSource.top,
                              shape: NeumorphicShape.convex,
                              depth: 2,
                              intensity: 0.2,
                              color: Colors.green,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(5),
                              ),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.indianRupeeSign,
                              size: 25,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: NeumorphicFloatingActionButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            sendMessage();
                          },
                          tooltip: 'Send message',
                          style: NeumorphicStyle(
                            lightSource: LightSource.top,
                            shape: NeumorphicShape.convex,
                            depth: 2,
                            intensity: 0.2,
                            color: blueColor,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(5),
                            ),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.solidPaperPlane,
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
