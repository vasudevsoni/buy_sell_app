import 'package:buy_sell_app/screens/chats/conversation_screen.dart';
import 'package:buy_sell_app/screens/full_decription_screen.dart';
import 'package:buy_sell_app/screens/profile_screen.dart';
import 'package:buy_sell_app/screens/selling/edit_vehicle_ad_screen.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:buy_sell_app/widgets/custom_product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/firebase_services.dart';
import 'category_products_screen.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details-screen';
  DocumentSnapshot productData;
  DocumentSnapshot sellerData;
  ProductDetailsScreen({
    super.key,
    required this.productData,
    required this.sellerData,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirebaseServices services = FirebaseServices();
  int currentImage = 0;
  CarouselController controller = CarouselController();
  List fav = [];
  bool isLiked = false;
  String profileImage = '';

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

    Navigator.of(context).push(
      PageTransition(
        child: ConversationScreen(
          chatRoomId: chatRoomId,
          prodId: widget.productData.id,
          sellerId: widget.productData['sellerUid'],
        ),
        type: PageTransitionType.rightToLeftWithFade,
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      widget.sellerData['profileImage'] == null
          ? profileImage = ''
          : profileImage = widget.sellerData['profileImage'];
    });
    getFavorites();
    super.initState();
  }

  getFavorites() {
    services.listings.doc(widget.productData.id).get().then((value) {
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

    void handleClick(String value) {
      switch (value) {
        case 'Share':
          break;
        case 'Report this item':
          break;
        case 'Help & Contact':
          break;
      }
    }

    return Scaffold(
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
              Iconsax.direct_send4,
              color: blackColor,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          PopupMenuButton(
            onSelected: handleClick,
            icon: const Icon(
              Iconsax.more4,
              size: 20,
            ),
            splashRadius: 1,
            padding: const EdgeInsets.all(0),
            enableFeedback: true,
            position: PopupMenuPosition.under,
            tooltip: 'Options',
            color: Colors.white,
            offset: const Offset(-10, 10),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 1,
                color: blackColor,
                strokeAlign: StrokeAlign.inside,
                style: BorderStyle.solid,
              ),
            ),
            itemBuilder: (BuildContext context) {
              return {'Share', 'Report this item', 'Help & Contact'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  textStyle: GoogleFonts.poppins(
                    color: blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Item',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.productData['sellerUid'] == services.user!.uid)
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      PageController pageController =
                          PageController(initialPage: currentImage);
                      return Dismissible(
                        key: const Key('photosKey'),
                        direction: DismissDirection.down,
                        onDismissed: (direction) {
                          Navigator.pop(context);
                        },
                        child: Material(
                          color: Colors.black,
                          child: Stack(
                            children: [
                              PhotoViewGallery.builder(
                                scrollPhysics: const BouncingScrollPhysics(),
                                itemCount: images.length,
                                pageController: pageController,
                                builder: (BuildContext context, int index) {
                                  return PhotoViewGalleryPageOptions(
                                    imageProvider: NetworkImage(
                                      images[index],
                                    ),
                                    initialScale:
                                        PhotoViewComputedScale.contained * 1,
                                    minScale:
                                        PhotoViewComputedScale.contained * 1,
                                    maxScale:
                                        PhotoViewComputedScale.contained * 10,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Iconsax.warning_24,
                                        size: 20,
                                        color: redColor,
                                      );
                                    },
                                  );
                                },
                                loadingBuilder: (context, event) {
                                  return const Center(
                                    child: SpinKitFadingCube(
                                      color: greyColor,
                                      size: 20,
                                      duration: Duration(milliseconds: 1000),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 15,
                                left: 15,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    pageController.dispose();
                                  },
                                  splashColor: blueColor,
                                  splashRadius: 30,
                                  icon: const Icon(
                                    Iconsax.close_square4,
                                    size: 30,
                                    color: Colors.white,
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
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    Container(
                      color: greyColor,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: CarouselSlider.builder(
                        carouselController: controller,
                        itemCount: images.length,
                        itemBuilder: (context, index, realIndex) {
                          return CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Iconsax.warning_24,
                                size: 20,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Center(
                                child: SpinKitFadingCube(
                                  color: lightBlackColor,
                                  size: 20,
                                  duration: Duration(milliseconds: 1000),
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
                          scrollPhysics: const BouncingScrollPhysics(),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                    ? blueColor
                                    : fadedColor,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: Text(
                      widget.productData['title'],
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      priceFormat.format(
                        widget.productData['price'],
                      ),
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: blueColor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  widget.productData['sellerUid'] == services.user!.uid
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: CustomButton(
                            text: 'Edit listing',
                            onPressed: () {
                              widget.productData['catName'] == 'Vehicles'
                                  ? Navigator.of(context).push(
                                      PageTransition(
                                        child: EditVehicleAdScreen(
                                          productData: widget.productData,
                                        ),
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                      ),
                                    )
                                  : null;
                            },
                            icon: Iconsax.edit4,
                            bgColor: blackColor,
                            borderColor: blackColor,
                            textIconColor: Colors.white,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: CustomButton(
                            text: 'Chat with Seller',
                            onPressed: createChatRoom,
                            icon: Iconsax.message4,
                            bgColor: blueColor,
                            borderColor: blueColor,
                            textIconColor: Colors.white,
                          ),
                        ),
                  if (widget.productData['sellerUid'] != services.user!.uid)
                    const SizedBox(
                      height: 10,
                    ),
                  if (widget.productData['sellerUid'] != services.user!.uid)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomButton(
                        text: isLiked
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                          services.updateFavorite(
                            context: context,
                            isLiked: isLiked,
                            productId: widget.productData.id,
                          );
                        },
                        icon: isLiked ? Iconsax.heart_slash4 : Iconsax.heart5,
                        bgColor: isLiked ? blackColor : Colors.white,
                        borderColor: isLiked ? blackColor : redColor,
                        textIconColor: isLiked ? Colors.white : redColor,
                      ),
                    ),
                  const SizedBox(
                    height: 25,
                  ),
                  widget.productData['catName'] == 'Vehicles'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(15),
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
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.60,
                                          child: Text(
                                            widget.productData['brandName'],
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
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
                                        Text(
                                          'Model - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.60,
                                          child: Text(
                                            widget.productData['modelName'],
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
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
                                        Text(
                                          'Color - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.60,
                                          child: Text(
                                            widget.productData['color'],
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
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
                                          Iconsax.user4,
                                          size: 15,
                                          color: lightBlackColor,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Owner - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          widget.productData['noOfOwners'],
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
                                          Iconsax.gas_station3,
                                          size: 15,
                                          color: lightBlackColor,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Fuel Type - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          widget.productData['fuelType'],
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
                                          Iconsax.calendar,
                                          size: 15,
                                          color: lightBlackColor,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Year of Reg. - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          widget.productData['yearOfReg']
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
                                          Iconsax.location_tick4,
                                          size: 15,
                                          color: lightBlackColor,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Kms Driven - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          kmFormat.format(
                                            widget.productData['kmsDriven'],
                                          ),
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
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
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageTransition(
                                            child: CategoryProductsScreen(
                                              catName:
                                                  widget.productData['catName'],
                                              subCatName:
                                                  widget.productData['subCat'],
                                            ),
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Iconsax.category4,
                                            size: 15,
                                            color: lightBlackColor,
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            'Category - ',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: lightBlackColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.40,
                                            child: Text(
                                              '${widget.productData['catName']} > ${widget.productData['subCat']}',
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: blackColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Iconsax.arrow_circle_right4,
                                            size: 13,
                                            color: blackColor,
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
                                          Iconsax.clock4,
                                          size: 15,
                                          color: lightBlackColor,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Posted - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(productCreatedTime),
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
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageTransition(
                                            child: CategoryProductsScreen(
                                              catName:
                                                  widget.productData['catName'],
                                              subCatName:
                                                  widget.productData['subCat'],
                                            ),
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Iconsax.category4,
                                            size: 15,
                                            color: lightBlackColor,
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            'Category - ',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: lightBlackColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.40,
                                            child: Text(
                                              '${widget.productData['catName']} > ${widget.productData['subCat']}',
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: blackColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Iconsax.arrow_circle_right4,
                                            size: 13,
                                            color: blackColor,
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
                                          Iconsax.clock4,
                                          size: 15,
                                          color: lightBlackColor,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Posted - ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: lightBlackColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(productCreatedTime),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageTransition(
                            child: FullDescriptionScreen(
                              desc: widget.productData['description'],
                            ),
                            type: PageTransitionType.rightToLeftWithFade,
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Hero(
                          tag: 'full-description',
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
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  if (widget.productData['sellerUid'] != services.user!.uid)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  child: ProfileScreen(
                                    userId: widget.sellerData['uid'],
                                  ),
                                  type: PageTransitionType.rightToLeftWithFade,
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius: BorderRadius.circular(15),
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
                                            Iconsax.security_user4,
                                            color: Colors.white,
                                            size: 15,
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
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget.sellerData['name'] == null
                                          ? SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: Text(
                                                'Name not disclosed',
                                                maxLines: 1,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
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
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: blackColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                      Text(
                                        'Joined - ${timeago.format(sellerJoinTime)}',
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
                                    Iconsax.arrow_circle_right4,
                                    color: blackColor,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                ],
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
    var priceFormat = NumberFormat.currency(
      locale: 'HI',
      decimalDigits: 0,
      symbol: '₹ ',
      name: '',
    );

    return StreamBuilder<QuerySnapshot>(
      stream: _services.listings
          .where('catName', isEqualTo: widget.catName)
          .where('subCat', isEqualTo: widget.subCatName)
          .where(
            'postedAt',
            isNotEqualTo: widget.productId,
          )
          .snapshots(),
      builder: (context, snapshot) {
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
        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          padding: const EdgeInsets.only(
            left: 10,
            top: 0,
            right: 10,
            bottom: 30,
          ),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: snapshot.data!.size >= 4 ? 4 : snapshot.data!.size,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            var time = DateTime.fromMillisecondsSinceEpoch(data['postedAt']);
            var sellerDetails = _services.getUserData(data['sellerUid']);

            return CustomProductCard(
              data: data,
              sellerDetails: sellerDetails,
              priceFormat: priceFormat,
              time: time,
            );
          },
          physics: const BouncingScrollPhysics(),
        );
      },
    );
  }
}
