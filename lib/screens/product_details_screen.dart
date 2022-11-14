import 'package:buy_sell_app/promotion/promote_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import 'all_images_display_screen.dart';
import '/screens/help_and_support_screen.dart';
import '/screens/selling/common/edit_ad_screen.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';
import 'category_products_screen.dart';
import '/screens/chats/conversation_screen.dart';
import 'full_decription_screen.dart';
import 'profile_screen.dart';
import '/screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  final DocumentSnapshot productData;
  final DocumentSnapshot sellerData;
  const ProductDetailsScreen({
    super.key,
    required this.productData,
    required this.sellerData,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirebaseServices services = FirebaseServices();
  final TextEditingController reportTextController = TextEditingController();
  int currentImage = 0;
  List fav = [];
  bool isLiked = false;
  String profileImage = '';
  bool isActive = true;
  bool isSold = false;
  bool isLoading = false;
  String location = '';

  NumberFormat numberFormat = NumberFormat.compact();

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  getDetails() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      setState(() {
        widget.sellerData['profileImage'] == null
            ? profileImage = ''
            : profileImage = widget.sellerData['profileImage'];
        location =
            '${widget.productData['location']['area']}, ${widget.productData['location']['city']}, ${widget.productData['location']['state']}';
      });
      if (widget.productData['isActive'] == false) {
        setState(() {
          isActive = false;
        });
      } else {
        setState(() {
          isActive = true;
        });
      }
      if (widget.productData['isSold'] == false) {
        setState(() {
          isSold = false;
        });
      } else {
        setState(() {
          isSold = true;
        });
      }
      await services.listings.doc(widget.productData.id).get().then((value) {
        setState(() {
          fav = value['favorites'];
        });
        if (!fav.contains(services.user!.uid)) {
          setState(() {
            isLiked = false;
          });
          return;
        }
        setState(() {
          isLiked = true;
        });
      });
      if (services.user!.uid != widget.productData['sellerUid']) {
        await services.listings.doc(widget.productData.id).update({
          'views': FieldValue.arrayUnion([services.user!.uid]),
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  createChatRoom() {
    Map<String, dynamic> product = {
      'productId': widget.productData.id,
      'productImage': widget.productData['images'][0],
      'price': widget.productData['price'],
      'title': widget.productData['title'],
      'seller': widget.productData['sellerUid'],
    };

    List<String> users = [
      widget.sellerData['uid'], //seller uid
      services.user!.uid, //buyer uid
    ];

    String chatRoomId =
        '${widget.sellerData['uid']}.${services.user!.uid}.${widget.productData.id}';

    Map<String, dynamic> chatData = {
      'users': users,
      'chatRoomId': chatRoomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };

    services.createChatRoomInFirebase(chatData: chatData);
    Get.to(
      () => ConversationScreen(
        chatRoomId: chatRoomId,
        prodId: widget.productData.id,
        sellerId: widget.productData['sellerUid'],
      ),
    );
  }

  @override
  void dispose() {
    reportTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var sellerJoinTime = DateTime.fromMillisecondsSinceEpoch(
      widget.sellerData['dateJoined'],
    );
    var productCreatedTime = DateTime.fromMillisecondsSinceEpoch(
      widget.productData['postedAt'],
    );
    List images = widget.productData['images'];

    showReportDialog() {
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
                right: 15,
                top: 15,
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
                    'Report this product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: reportTextController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    showCounterText: true,
                    maxLength: 1000,
                    maxLines: 3,
                    label: 'Message',
                    hint:
                        'Explain in detail why you are reporting this product',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "To include a screenshot with your report, please",
                      children: [
                        TextSpan(
                          text: " go to Help and Support",
                          style: const TextStyle(
                            color: blueColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.back();
                              Get.to(() => const HelpAndSupportScreen());
                            },
                        ),
                        const TextSpan(
                          text: " section and report from there.",
                          style: TextStyle(
                            color: lightBlackColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      style: const TextStyle(
                        color: lightBlackColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    icon: FontAwesomeIcons.bug,
                    text: 'Report Product',
                    onPressed: () {
                      if (reportTextController.text.isEmpty) {
                        return;
                      }
                      services.reportItem(
                        listingId: widget.productData.id,
                        message: reportTextController.text,
                      );
                      Get.back();
                      reportTextController.clear();
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
                    icon: FontAwesomeIcons.shareNodes,
                    text: 'Share Product',
                    onPressed: () {},
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    icon: FontAwesomeIcons.bug,
                    text: 'Report Product',
                    onPressed: () {
                      Get.back();
                      showReportDialog();
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

    return isActive == false && isSold == false
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: whiteColor,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: blackColor),
              centerTitle: true,
              title: const Text(
                'Product',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                  fontSize: 15,
                ),
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(15),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This product is currently unavailable.',
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: redColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'The reasons for this may include but are not limited to -',
                            style: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '1) The product is currently under review and will be activated once it is found valid.',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '2) The product goes against our guidelines and has been disabled temporarily or permanently.',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '3) The product has been sold.',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              actions: isSold
                  ? []
                  : [
                      GestureDetector(
                        onTap: () async {
                          var url = Uri.parse(widget.productData['images'][0]);
                          Share.share(
                            'I found this ${widget.productData['title']} at ${priceFormat.format(widget.productData['price'])} on BestDeal.🤩\nCheck it out now - $url',
                            subject:
                                'Wow! Look at this deal I found on BestDeal.',
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(
                          FontAwesomeIcons.shareNodes,
                          color: blackColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
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
              elevation: 0.5,
              iconTheme: const IconThemeData(color: blackColor),
              centerTitle: true,
              title: const Text(
                'Product',
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
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSold == true)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            color: redColor,
                            child: const Center(
                              child: Text(
                                'This product has been sold',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () => images.length >= 2
                              ? Get.to(
                                  () => AllImagesDisplayScreen(
                                    images: images,
                                  ),
                                )
                              : showDialog(
                                  context: context,
                                  builder: (context) {
                                    PageController pageController =
                                        PageController(
                                            initialPage: currentImage);
                                    return Dismissible(
                                      key: UniqueKey(),
                                      direction: DismissDirection.down,
                                      onDismissed: (direction) {
                                        pageController.dispose();
                                        Get.back();
                                      },
                                      child: Material(
                                        color: blackColor,
                                        child: Stack(
                                          children: [
                                            PhotoViewGallery.builder(
                                              scrollPhysics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: images.length,
                                              pageController: pageController,
                                              builder: (BuildContext context,
                                                  int index) {
                                                return PhotoViewGalleryPageOptions(
                                                  imageProvider: NetworkImage(
                                                    images[index],
                                                  ),
                                                  initialScale:
                                                      PhotoViewComputedScale
                                                              .contained *
                                                          1,
                                                  minScale:
                                                      PhotoViewComputedScale
                                                              .contained *
                                                          1,
                                                  maxScale:
                                                      PhotoViewComputedScale
                                                              .contained *
                                                          10,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                      FontAwesomeIcons
                                                          .circleExclamation,
                                                      size: 20,
                                                      color: redColor,
                                                    );
                                                  },
                                                );
                                              },
                                              loadingBuilder: (context, event) {
                                                return const Center(
                                                  child: SpinKitFadingCircle(
                                                    color: greyColor,
                                                    size: 20,
                                                    duration: Duration(
                                                        milliseconds: 1000),
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: 15,
                                              right: 15,
                                              child: IconButton(
                                                onPressed: () {
                                                  pageController.dispose();
                                                  Get.back();
                                                },
                                                splashColor: blueColor,
                                                splashRadius: 30,
                                                icon: const Icon(
                                                  FontAwesomeIcons.circleXmark,
                                                  size: 30,
                                                  color: whiteColor,
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
                                ),
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            children: [
                              Container(
                                color: blackColor,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: CarouselSlider.builder(
                                  itemCount: images.length,
                                  itemBuilder: (context, index, realIndex) {
                                    return CachedNetworkImage(
                                      imageUrl: images[index],
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                                        return const Icon(
                                          FontAwesomeIcons.circleExclamation,
                                          size: 20,
                                          color: redColor,
                                        );
                                      },
                                      placeholder: (context, url) {
                                        return const Center(
                                          child: SpinKitFadingCircle(
                                            color: greyColor,
                                            size: 20,
                                            duration:
                                                Duration(milliseconds: 1000),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  options: CarouselOptions(
                                    viewportFraction: 1,
                                    height: MediaQuery.of(context).size.height,
                                    enlargeCenterPage: false,
                                    enableInfiniteScroll:
                                        images.length == 1 ? false : true,
                                    initialPage: currentImage,
                                    reverse: false,
                                    scrollDirection: Axis.horizontal,
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentImage = index;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: lightBlackColor,
                                  ),
                                  child: Text(
                                    '${currentImage + 1}/${widget.productData['images'].length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: whiteColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              if (images.length > 1)
                                Positioned(
                                  bottom: 7,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: images.map((url) {
                                      int index = images.indexOf(url);
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.only(
                                          left: 2,
                                          right: 2,
                                          top: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentImage == index
                                              ? blueColor
                                              : lightBlackColor,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  priceFormat.format(
                                    widget.productData['price'],
                                  ),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: blueColor,
                                    fontSize: 18,
                                    decoration: isSold
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.eye,
                                    size: 16,
                                    color: blueColor,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    numberFormat.format(
                                        widget.productData['views'].length),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.heart,
                                    size: 16,
                                    color: pinkColor,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    numberFormat.format(
                                        widget.productData['favorites'].length),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            widget.productData['title'],
                            maxLines: 3,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: blackColor,
                              fontSize: 18,
                              decoration: isSold
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.locationDot,
                                size: 12,
                                color: lightBlackColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  location,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: lightBlackColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.clock,
                                size: 12,
                                color: lightBlackColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  timeago.format(productCreatedTime),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: lightBlackColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        widget.productData['sellerUid'] == services.user!.uid &&
                                isSold == false
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: CustomButton(
                                      text: 'Promote Product',
                                      onPressed: () => Get.to(
                                        () => PromoteListingScreen(
                                          productId: widget.productData.id,
                                        ),
                                      ),
                                      icon: FontAwesomeIcons.moneyBill1Wave,
                                      bgColor: blueColor,
                                      borderColor: blueColor,
                                      textIconColor: whiteColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: CustomButton(
                                      text: 'Edit Product',
                                      onPressed: () => widget
                                                  .productData['catName'] ==
                                              'Vehicles'
                                          ? Get.to(
                                              () => EditVehicleAdScreen(
                                                productData: widget.productData,
                                              ),
                                            )
                                          : Get.to(
                                              () => EditAdScreen(
                                                productData: widget.productData,
                                              ),
                                            ),
                                      icon: FontAwesomeIcons.solidPenToSquare,
                                      bgColor: whiteColor,
                                      borderColor: blackColor,
                                      textIconColor: blackColor,
                                    ),
                                  ),
                                ],
                              )
                            : isSold == false
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: CustomButton(
                                      text: 'Chat with Seller',
                                      onPressed: createChatRoom,
                                      icon: FontAwesomeIcons.solidComment,
                                      bgColor: blueColor,
                                      borderColor: blueColor,
                                      textIconColor: whiteColor,
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                    width: 0,
                                  ),
                        if (widget.productData['sellerUid'] !=
                                services.user!.uid &&
                            isSold == false)
                          const SizedBox(
                            height: 10,
                          ),
                        if (widget.productData['sellerUid'] !=
                            services.user!.uid)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: CustomButton(
                              text: isLiked
                                  ? 'Added to Favorites'
                                  : 'Add to Favorites',
                              onPressed: () async {
                                setState(() {
                                  isLiked = !isLiked;
                                });
                                await services.updateFavorite(
                                  isLiked: isLiked,
                                  productId: widget.productData.id,
                                );
                              },
                              icon: isLiked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              bgColor: whiteColor,
                              borderColor: pinkColor,
                              textIconColor: pinkColor,
                            ),
                          ),
                        const SizedBox(
                          height: 25,
                        ),
                        widget.productData['catName'] == 'Vehicles'
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'About this product',
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: blackColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: greyColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Brand - ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                widget.productData['brandName'],
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Model - ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                widget.productData['modelName'],
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Color - ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                widget.productData['color'],
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            height: 20,
                                            color: fadedColor,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.user,
                                                size: 15,
                                                color: blueColor,
                                              ),
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              const Text(
                                                'Owner',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                widget
                                                    .productData['noOfOwners'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.gasPump,
                                                size: 15,
                                                color: blueColor,
                                              ),
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              const Text(
                                                'Fuel Type',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                widget.productData['fuelType'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.calendar,
                                                size: 15,
                                                color: blueColor,
                                              ),
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              const Text(
                                                'Year of Reg.',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                widget.productData['yearOfReg']
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.road,
                                                size: 15,
                                                color: blueColor,
                                              ),
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              const Text(
                                                'Kms Driven',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: lightBlackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                kmFormat.format(
                                                  widget
                                                      .productData['kmsDriven'],
                                                ),
                                                maxLines: 2,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => Get.to(
                                              () => CategoryProductsScreen(
                                                catName: widget
                                                    .productData['catName'],
                                                subCatName: widget
                                                    .productData['subCat'],
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  FontAwesomeIcons.list,
                                                  size: 15,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                const Text(
                                                  'Category',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: AutoSizeText(
                                                    '${widget.productData['catName']} > ${widget.productData['subCat']}',
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: blackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'About this product',
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: blackColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: greyColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => Get.to(
                                              () => CategoryProductsScreen(
                                                catName: widget
                                                    .productData['catName'],
                                                subCatName: widget
                                                    .productData['subCat'],
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  FontAwesomeIcons.list,
                                                  size: 15,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                const Text(
                                                  'Category',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: AutoSizeText(
                                                    '${widget.productData['catName']} > ${widget.productData['subCat']}',
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    textAlign: TextAlign.end,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: blackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'Product description from the seller',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Get.to(
                            () => FullDescriptionScreen(
                              desc: widget.productData['description'],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: greyColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Text(
                              widget.productData['description'],
                              maxLines: 5,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: blackColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        if (widget.productData['sellerUid'] !=
                            services.user!.uid)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'About this seller',
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: blackColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Get.to(
                                  () => ProfileScreen(
                                    userId: widget.sellerData['uid'],
                                  ),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: greyColor,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      profileImage == ''
                                          ? Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: blueColor,
                                              ),
                                              child: const Icon(
                                                FontAwesomeIcons.userTie,
                                                color: whiteColor,
                                                size: 20,
                                              ),
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: CachedNetworkImage(
                                                  imageUrl: profileImage,
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return const Icon(
                                                      FontAwesomeIcons
                                                          .circleExclamation,
                                                      size: 10,
                                                      color: redColor,
                                                    );
                                                  },
                                                  placeholder: (context, url) {
                                                    return const Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        color: lightBlackColor,
                                                        size: 10,
                                                        duration: Duration(
                                                            milliseconds: 1000),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.sellerData['name'] == null
                                              ? SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: const Text(
                                                    'BestDeal User',
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: blackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: Text(
                                                    widget.sellerData['name'],
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: blackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                          Text(
                                            'Joined ${timeago.format(sellerJoinTime)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: fadedColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        FontAwesomeIcons.chevronRight,
                                        color: blackColor,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(
                          height: 25,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'You might also like',
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        MoreLikeThisProductsList(
                          catName: widget.productData['catName'],
                          subCatName: widget.productData['subCat'],
                        ),
                      ],
                    ),
                  ),
          );
  }
}

class MoreLikeThisProductsList extends StatefulWidget {
  final String catName;
  final String subCatName;
  const MoreLikeThisProductsList({
    super.key,
    required this.catName,
    required this.subCatName,
  });

  @override
  State<MoreLikeThisProductsList> createState() =>
      _MoreLikeThisProductsListState();
}

class _MoreLikeThisProductsListState extends State<MoreLikeThisProductsList> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _services.listings
          .where('catName', isEqualTo: widget.catName)
          .where('subCat', isEqualTo: widget.subCatName)
          .where('')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
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
          return const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                'No similar products found',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCircle(
                color: lightBlackColor,
                size: 20,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                bottom: 10,
              ),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.size >= 4 ? 4 : snapshot.data!.size,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                var time =
                    DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
                var sellerDetails = _services.getUserData(data['sellerUid']);
                return CustomProductCard(
                  data: data,
                  sellerDetails: sellerDetails,
                  time: time,
                );
              },
              physics: const NeverScrollableScrollPhysics(),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                bottom: 15,
                right: 15,
              ),
              child: CustomButton(
                text: 'See More in ${widget.subCatName}',
                onPressed: () => Get.to(
                  () => CategoryProductsScreen(
                    catName: widget.catName,
                    subCatName: widget.subCatName,
                  ),
                ),
                icon: FontAwesomeIcons.chevronRight,
                borderColor: blueColor,
                bgColor: blueColor,
                textIconColor: whiteColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
