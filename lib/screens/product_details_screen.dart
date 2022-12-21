import 'package:buy_sell_app/promotion/promote_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/text_field_label.dart';
import 'all_images_display_screen.dart';
import '/screens/selling/common/edit_ad_screen.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button_without_icon.dart';
import 'category_products_screen.dart';
import '/screens/chats/conversation_screen.dart';
import 'full_decription_screen.dart';
import 'help_and_support_screen.dart';
import '/screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_product_card.dart';
import 'profile_screen.dart';

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
  final MapController mapController = MapController();
  int currentImage = 0;
  List fav = [];
  bool isLiked = false;
  String profileImage = '';
  bool isActive = true;
  bool isSold = false;
  bool isLoading = false;
  String location = '';
  double latitude = 0;
  double longitude = 0;

  final NumberFormat numberFormat = NumberFormat.compact();

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
        latitude = widget.productData['location']['latitude'];
        longitude = widget.productData['location']['longitude'];
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
    final Map<String, dynamic> product = {
      'productId': widget.productData.id,
      'productImage': widget.productData['images'][0],
      'price': widget.productData['price'],
      'title': widget.productData['title'],
      'seller': widget.productData['sellerUid'],
    };

    final List<String> users = [
      widget.sellerData['uid'],
      services.user!.uid,
    ];

    final String chatRoomId =
        '${widget.sellerData['uid']}.${services.user!.uid}.${widget.productData.id}';

    final Map<String, dynamic> chatData = {
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
    mapController.dispose();
    reportTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sellerJoinTime = DateTime.fromMillisecondsSinceEpoch(
      widget.sellerData['dateJoined'],
    );
    final productCreatedTime = DateTime.fromMillisecondsSinceEpoch(
      widget.productData['postedAt'],
    );
    final List images = widget.productData['images'];

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
                top: 5,
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
                  const Center(
                    child: Text(
                      'Report this product',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const TextFieldLabel(labelText: 'Message'),
                  CustomTextField(
                    controller: reportTextController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    showCounterText: true,
                    maxLength: 1000,
                    maxLines: 3,
                    hint:
                        'Explain in detail why you are reporting this product',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "To include a screenshot with your report, please",
                      children: [
                        TextSpan(
                          text: " go to Help and Support",
                          style: const TextStyle(
                            color: blueColor,
                            fontSize: 14,
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
                            fontSize: 14,
                          ),
                        ),
                      ],
                      style: const TextStyle(
                        color: lightBlackColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    icon: Ionicons.arrow_forward,
                    text: 'Submit',
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
              padding: const EdgeInsets.only(
                top: 5,
                left: 15,
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
                    child: CustomButton(
                      icon: Ionicons.flag,
                      text: 'Report Product',
                      onPressed: () {
                        Get.back();
                        showReportDialog();
                      },
                      bgColor: whiteColor,
                      borderColor: redColor,
                      textIconColor: redColor,
                    ),
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
            backgroundColor: whiteColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              elevation: 0.2,
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
                      width: size.width,
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
              elevation: 0.2,
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
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSold == true)
                          Container(
                            width: size.width,
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
                                                  const ClampingScrollPhysics(),
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
                                                      Ionicons.alert_circle,
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
                                                    size: 30,
                                                    duration: Duration(
                                                      milliseconds: 1000,
                                                    ),
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
                                                  Ionicons.close_circle_outline,
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
                                width: size.width,
                                height: size.height * 0.35,
                                child: CarouselSlider.builder(
                                  itemCount: images.length,
                                  itemBuilder: (context, index, realIndex) {
                                    return CachedNetworkImage(
                                      imageUrl: images[index],
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) {
                                        return const Icon(
                                          Ionicons.alert_circle,
                                          size: 20,
                                          color: redColor,
                                        );
                                      },
                                      placeholder: (context, url) {
                                        return const Center(
                                          child: SpinKitFadingCircle(
                                            color: greyColor,
                                            size: 30,
                                            duration:
                                                Duration(milliseconds: 1000),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  options: CarouselOptions(
                                    viewportFraction: 1,
                                    height: size.height,
                                    enlargeCenterPage: false,
                                    enableInfiniteScroll:
                                        images.length == 1 ? false : true,
                                    initialPage: currentImage,
                                    reverse: false,
                                    scrollDirection: Axis.horizontal,
                                    scrollPhysics:
                                        const ClampingScrollPhysics(),
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
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: lightBlackColor,
                                  ),
                                  child: Text(
                                    '${currentImage + 1}/${widget.productData['images'].length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: whiteColor,
                                      fontSize: 12,
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
                                              : greyColor,
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
                            left: 15,
                            right: 15,
                            top: 15,
                          ),
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
                                    fontWeight: FontWeight.w800,
                                    color: blackColor,
                                    fontSize: 17,
                                    decoration: isSold
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Ionicons.eye_outline,
                                    size: 20,
                                    color: blueColor,
                                  ),
                                  const SizedBox(
                                    width: 3,
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Ionicons.heart_outline,
                                    size: 20,
                                    color: redColor,
                                  ),
                                  const SizedBox(
                                    width: 3,
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
                        const SizedBox(
                          height: 3,
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
                              fontSize: 15,
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
                                Ionicons.list_outline,
                                size: 15,
                                color: lightBlackColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(text: 'In '),
                                      TextSpan(
                                        text:
                                            '${widget.productData['catName']} > ${widget.productData['subCat']}',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.to(
                                                () => CategoryProductsScreen(
                                                  catName: widget
                                                      .productData['catName'],
                                                  subCatName: widget
                                                      .productData['subCat'],
                                                ),
                                                transition: Transition.downToUp,
                                              ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: blueColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: lightBlackColor,
                                      fontSize: 14,
                                    ),
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
                                Ionicons.location_outline,
                                size: 15,
                                color: lightBlackColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  location,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              const Icon(
                                Ionicons.time_outline,
                                size: 15,
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
                                      text: 'Reach More Buyers',
                                      onPressed: () => Get.to(
                                        () => PromoteListingScreen(
                                          productId: widget.productData.id,
                                          title: widget.productData['title'],
                                          price: widget.productData['price']
                                              .toDouble(),
                                          imageUrl: widget.productData['images']
                                              [0],
                                        ),
                                      ),
                                      icon: Ionicons.trending_up,
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
                                      icon: Ionicons.create_outline,
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
                                      icon: Ionicons.chatbox,
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
                                  ? Ionicons.heart
                                  : Ionicons.heart_outline,
                              bgColor: whiteColor,
                              borderColor: redColor,
                              textIconColor: redColor,
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
                                      width: size.width,
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
                                              Expanded(
                                                child: Text(
                                                  widget
                                                      .productData['brandName'],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: blackColor,
                                                    fontSize: 15,
                                                  ),
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
                                              Expanded(
                                                child: Text(
                                                  widget
                                                      .productData['modelName'],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: blackColor,
                                                    fontSize: 15,
                                                  ),
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
                                              Expanded(
                                                child: Text(
                                                  widget.productData['color'],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: blackColor,
                                                    fontSize: 15,
                                                  ),
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
                                                Ionicons.person,
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
                                                Ionicons.funnel,
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
                                                Ionicons.calendar,
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
                                                Ionicons.car_sport,
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                                width: 0,
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
                            width: size.width,
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
                        const SizedBox(
                          height: 20,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'Product Location',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: SizedBox(
                            height: size.height * 0.3,
                            width: size.width,
                            child: FlutterMap(
                              mapController: mapController,
                              options: MapOptions(
                                center: LatLng(
                                  latitude,
                                  longitude,
                                ),
                                zoom: 15.0,
                                maxZoom: 16.0,
                                maxBounds: LatLngBounds(
                                  LatLng(-90, -180.0),
                                  LatLng(90.0, 180.0),
                                ),
                                interactiveFlags: InteractiveFlag.all &
                                    ~InteractiveFlag.rotate,
                              ),
                              nonRotatedChildren: [
                                AttributionWidget.defaultWidget(
                                  source: 'OpenStreetMap contributors',
                                ),
                              ],
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.bechde.buy_sell_app',
                                  subdomains: const ['a', 'b', 'c'],
                                  backgroundColor: greyColor,
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: LatLng(
                                        latitude,
                                        longitude,
                                      ),
                                      radius: 40,
                                      borderColor: blueColor,
                                      borderStrokeWidth: 5,
                                      color: fadedColor,
                                    ),
                                  ],
                                ),
                              ],
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
                                  width: size.width,
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
                                              height: size.width * 0.1,
                                              width: size.width * 0.1,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: blueColor,
                                              ),
                                              child: const Icon(
                                                Ionicons.person,
                                                color: whiteColor,
                                                size: 20,
                                              ),
                                            )
                                          : SizedBox(
                                              height: size.width * 0.1,
                                              width: size.width * 0.1,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: CachedNetworkImage(
                                                  imageUrl: profileImage,
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return const Icon(
                                                      Ionicons.alert_circle,
                                                      size: 10,
                                                      color: redColor,
                                                    );
                                                  },
                                                  placeholder: (context, url) {
                                                    return const Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        color: lightBlackColor,
                                                        size: 20,
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
                                                  width: size.width * 0.5,
                                                  child: const Text(
                                                    'BechDe User',
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
                                                  width: size.width * 0.5,
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
                                        Ionicons.chevron_forward,
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
                          postedAt: widget.productData['postedAt'],
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
  final int postedAt;
  const MoreLikeThisProductsList({
    super.key,
    required this.catName,
    required this.subCatName,
    required this.postedAt,
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
          .where('postedAt', isNotEqualTo: widget.postedAt)
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
                size: 30,
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
                  height: 10,
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
                final data = snapshot.data!.docs[index];
                final time =
                    DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
                final sellerDetails = _services.getUserData(data['sellerUid']);
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
                text: 'See more similar products',
                onPressed: () => Get.to(
                  () => CategoryProductsScreen(
                    catName: widget.catName,
                    subCatName: widget.subCatName,
                  ),
                ),
                icon: Ionicons.chevron_forward,
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
