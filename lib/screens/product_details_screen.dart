import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/all_images_display_screen.dart';
import 'package:buy_sell_app/screens/selling/common/edit_ad_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/firebase_services.dart';
import '../widgets/custom_button_without_icon.dart';
import '../widgets/custom_text_field.dart';
import 'category_products_screen.dart';
import '../screens/chats/conversation_screen.dart';
import '../screens/full_decription_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/selling/vehicles/edit_vehicle_ad_screen.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_product_card.dart';

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
  bool isLoading = false;
  String location = '';

  NumberFormat numberFormat = NumberFormat.compact();
  var priceFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '₹ ',
    name: '',
  );
  var kmFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '',
    name: '',
  );

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    setState(() {
      widget.sellerData['profileImage'] == null
          ? profileImage = ''
          : profileImage = widget.sellerData['profileImage'];
    });
    if (widget.productData['isActive'] == false) {
      setState(() {
        isActive = false;
      });
    } else {
      setState(() {
        isActive = true;
        location =
            '${widget.productData['location']['area']}, ${widget.productData['location']['city']}, ${widget.productData['location']['state']}';
      });
    }
    await services.listings.doc(widget.productData.id).get().then((value) {
      setState(() {
        fav = value['favorites'];
      });
      if (fav.contains(services.user!.uid)) {
        setState(() {
          isLiked = true;
        });
      } else {
        setState(() {
          isLiked = false;
        });
      }
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

  createChatRoom() {
    Map<String, dynamic> product = {
      'productId': widget.productData['postedAt'],
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
        '${widget.sellerData['uid']}.${services.user!.uid}.${widget.productData['postedAt']}';

    Map<String, dynamic> chatData = {
      'users': users,
      'chatRoomId': chatRoomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };

    services.createChatRoomInFirebase(
      chatData: chatData,
      context: context,
    );
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
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: ShapeDecoration(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: whiteColor,
              ),
              margin: const EdgeInsets.all(15),
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
                  Text(
                    'File a Report',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const CustomTextField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    showCounterText: true,
                    maxLength: 1000,
                    maxLines: 3,
                    label: 'Message',
                    hint:
                        'Explain in detail the problem you are facing with this item',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    icon: FontAwesomeIcons.bug,
                    text: 'Report item',
                    onPressed: () {
                      if (reportTextController.text.isNotEmpty) {
                        // services.reportItem(
                        //   listingId: widget.productData.id,
                        //   message: reportTextController.text,
                        //   context: context,
                        // );
                        Get.back();
                      }
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
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: ShapeDecoration(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: whiteColor,
              ),
              margin: const EdgeInsets.all(15),
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
                    icon: FontAwesomeIcons.solidShareFromSquare,
                    text: 'Share item',
                    onPressed: () {},
                    bgColor: greyColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    icon: FontAwesomeIcons.bug,
                    text: 'Report item',
                    onPressed: () {
                      Get.back();
                      showReportDialog();
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

    return isActive == false
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: whiteColor,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: blackColor),
              centerTitle: true,
              title: Text(
                'Item',
                style: GoogleFonts.poppins(
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
                    Text(
                      'This item is currently unavailable.',
                      style: GoogleFonts.poppins(
                        color: blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: ShapeDecoration(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: redColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The reasons for this may include but are not limited to:',
                            style: GoogleFonts.poppins(
                              color: whiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            '1) The item is currently under review and will be activated once it is found valid.',
                            style: GoogleFonts.poppins(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '2) The item goes against our guidelines and has been disabled temporarily or permanently.',
                            style: GoogleFonts.poppins(
                              color: whiteColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '3) The item has already been sold.',
                            style: GoogleFonts.poppins(
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
              actions: [
                GestureDetector(
                  onTap: () async {
                    var url = Uri.parse(widget.productData['images'][0]);
                    Share.share(
                      'I found this ${widget.productData['title']} at ${priceFormat.format(widget.productData['price'])} on BestDeal.🤩\nCheck it out now - $url',
                      subject: 'Wow! Look at this deal I found on BestDeal.',
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    FontAwesomeIcons.solidShareFromSquare,
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
              title: Text(
                'Item',
                style: GoogleFonts.poppins(
                  color: blackColor,
                  fontSize: 15,
                ),
              ),
            ),
            body: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Center(
                      child: SpinKitFadingCube(
                        color: lightBlackColor,
                        size: 30,
                        duration: Duration(milliseconds: 1000),
                      ),
                    ),
                  )
                : Scrollbar(
                    interactive: true,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.productData['sellerUid'] ==
                              services.user!.uid)
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              color: blueColor,
                              child: Center(
                                child: Text(
                                  'This is your listing',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: whiteColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
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
                                : showModal(
                                    configuration:
                                        const FadeScaleTransitionConfiguration(),
                                    context: context,
                                    builder: (context) {
                                      PageController pageController =
                                          PageController(
                                              initialPage: currentImage);
                                      return Dismissible(
                                        key: UniqueKey(),
                                        direction: DismissDirection.down,
                                        onDismissed: (direction) {
                                          Get.back();
                                          pageController.dispose();
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
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                        FontAwesomeIcons
                                                            .circleExclamation,
                                                        size: 20,
                                                        color: redColor,
                                                      );
                                                    },
                                                  );
                                                },
                                                loadingBuilder:
                                                    (context, event) {
                                                  return const Center(
                                                    child: SpinKitFadingCube(
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
                                                    Get.back();
                                                    pageController.dispose();
                                                  },
                                                  splashColor: blueColor,
                                                  splashRadius: 30,
                                                  icon: const Icon(
                                                    FontAwesomeIcons
                                                        .circleXmark,
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
                                            child: SpinKitFadingCube(
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
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                  top: 7,
                                  right: 7,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: ShapeDecoration(
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color: greyColor,
                                    ),
                                    child: Text(
                                      '${currentImage + 1} of ${widget.productData['images'].length}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: images.map((url) {
                                        int index = images.indexOf(url);
                                        return Container(
                                          width: 8.0,
                                          height: 8.0,
                                          margin: const EdgeInsets.only(
                                              left: 2, right: 2, top: 10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentImage == index
                                                ? whiteColor
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
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: blueColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.eye,
                                      size: 18,
                                      color: blueColor,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      numberFormat.format(
                                          widget.productData['views'].length),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
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
                                      size: 18,
                                      color: pinkColor,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      numberFormat.format(widget
                                          .productData['favorites'].length),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
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
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                color: blackColor,
                                fontSize: 16,
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
                                  width: 3,
                                ),
                                Text(
                                  location,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    color: lightBlackColor,
                                    fontSize: 12,
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
                                  width: 3,
                                ),
                                Text(
                                  timeago.format(productCreatedTime),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    color: lightBlackColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          widget.productData['sellerUid'] == services.user!.uid
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: CustomButton(
                                    text: 'Edit listing',
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
                                    borderColor: greyColor,
                                    textIconColor: blackColor,
                                  ),
                                )
                              : Padding(
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
                                ),
                          if (widget.productData['sellerUid'] !=
                              services.user!.uid)
                            const SizedBox(
                              height: 10,
                            ),
                          if (widget.productData['sellerUid'] !=
                              services.user!.uid)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: CustomButton(
                                text: isLiked
                                    ? 'Added to favorites'
                                    : 'Add to favorites',
                                onPressed: () async {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                  await services.updateFavorite(
                                    context: context,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'About this item',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          color: blackColor,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: ShapeDecoration(
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
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
                                                Text(
                                                  'Brand - ',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  widget
                                                      .productData['brandName'],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
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
                                                Text(
                                                  'Model - ',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  widget
                                                      .productData['modelName'],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
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
                                                Text(
                                                  'Color - ',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  widget.productData['color'],
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
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
                                                Text(
                                                  'Owner',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  widget.productData[
                                                      'noOfOwners'],
                                                  style: GoogleFonts.poppins(
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
                                                Text(
                                                  'Fuel Type',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  widget
                                                      .productData['fuelType'],
                                                  style: GoogleFonts.poppins(
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
                                                Text(
                                                  'Year of Reg.',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  widget
                                                      .productData['yearOfReg']
                                                      .toString(),
                                                  style: GoogleFonts.poppins(
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
                                                Text(
                                                  'Kms Driven',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  kmFormat.format(
                                                    widget.productData[
                                                        'kmsDriven'],
                                                  ),
                                                  maxLines: 2,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
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
                                                  Text(
                                                    'Category',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: lightBlackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
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
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                  FontAwesomeIcons.clock,
                                                  size: 15,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  'Posted',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  timeago.format(
                                                      productCreatedTime),
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: blackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'About this item',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          color: blackColor,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: ShapeDecoration(
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
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
                                                  Text(
                                                    'Category',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: lightBlackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
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
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                  FontAwesomeIcons.clock,
                                                  size: 15,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  'Posted',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: lightBlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  timeago.format(
                                                      productCreatedTime),
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: blackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Item description from the seller',
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                                fontSize: 17,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              width: MediaQuery.of(context).size.width,
                              decoration: ShapeDecoration(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
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
                                style: GoogleFonts.poppins(
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    'About this seller',
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: blackColor,
                                      fontSize: 17,
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
                                    decoration: ShapeDecoration(
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
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
                                                    placeholder:
                                                        (context, url) {
                                                      return const Center(
                                                        child:
                                                            SpinKitFadingCube(
                                                          color:
                                                              lightBlackColor,
                                                          size: 10,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  1000),
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      'BestDeal User',
                                                      maxLines: 1,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: blackColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      widget.sellerData['name'],
                                                      maxLines: 1,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: blackColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                            Text(
                                              'Joined ${timeago.format(sellerJoinTime)}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color: lightBlackColor,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'You might also like',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          MoreLikeThisProductsList(
                            catName: widget.productData['catName'],
                            subCatName: widget.productData['subCat'],
                            productId: widget.productData['postedAt'],
                          ),
                        ],
                      ),
                    ),
                  ),
          );
  }
}

class MoreLikeThisProductsList extends StatefulWidget {
  final String catName;
  final String subCatName;
  final int productId;
  const MoreLikeThisProductsList({
    super.key,
    required this.catName,
    required this.subCatName,
    required this.productId,
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
          .where(
            'postedAt',
            isNotEqualTo: widget.productId,
          )
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
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
                'No similar items found',
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
                text: 'See more in ${widget.subCatName}',
                onPressed: () => Get.to(
                  () => CategoryProductsScreen(
                    catName: widget.catName,
                    subCatName: widget.subCatName,
                  ),
                ),
                icon: FontAwesomeIcons.chevronRight,
                borderColor: blackColor,
                bgColor: blackColor,
                textIconColor: whiteColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
