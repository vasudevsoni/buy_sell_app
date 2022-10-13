import 'package:buy_sell_app/provider/product_provider.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details-screen';
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isDescExpanded = false;
  int currentImage = 0;
  CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    var sellerJoinTime = DateTime.fromMillisecondsSinceEpoch(
      provider.sellerData['dateJoined'],
    );
    var productCreatedTime = DateTime.fromMillisecondsSinceEpoch(
      provider.productData['postedAt'],
    );
    List images = provider.productData['images'];

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
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              FontAwesomeIcons.arrowUpFromBracket,
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
              FontAwesomeIcons.ellipsis,
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
              borderRadius: BorderRadius.circular(10),
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
        elevation: 0.2,
        backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    PageController pageController =
                        PageController(initialPage: currentImage);
                    return Material(
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
                                filterQuality: FilterQuality.high,
                                initialScale:
                                    PhotoViewComputedScale.contained * 1,
                                minScale: PhotoViewComputedScale.contained * 1,
                                maxScale: PhotoViewComputedScale.contained * 5,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    FontAwesomeIcons.triangleExclamation,
                                    size: 20,
                                    color: redColor,
                                  );
                                },
                              );
                            },
                            loadingBuilder: (context, event) {
                              return const Center(
                                child: SpinKitFadingCube(
                                  color: blueColor,
                                  size: 30,
                                  duration: Duration(milliseconds: 1000),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                pageController.dispose();
                              },
                              splashColor: blueColor,
                              splashRadius: 30,
                              icon: const Icon(
                                FontAwesomeIcons.xmark,
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
                    );
                  },
                );
              },
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
                              FontAwesomeIcons.triangleExclamation,
                              size: 20,
                              color: redColor,
                            );
                          },
                          placeholder: (context, url) {
                            return const Center(
                              child: SpinKitFadingCube(
                                color: blueColor,
                                size: 30,
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
                        enableInfiniteScroll: images.length == 1 ? false : true,
                        initialPage: currentImage,
                        reverse: false,
                        autoPlay: true,
                        autoPlayCurve: Curves.linear,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 1000),
                        pauseAutoPlayOnManualNavigate: true,
                        pauseAutoPlayOnTouch: true,
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
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: greyColor,
                      ),
                      child: Text(
                        '${currentImage + 1} of ${provider.productData['images'].length}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: blackColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((url) {
                int index = images.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.only(left: 2, right: 2, top: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImage == index ? blackColor : fadedColor,
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.productData['title'],
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    priceFormat.format(
                      provider.productData['price'],
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
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: 'Contact Seller',
                    onPressed: () {},
                    icon: FontAwesomeIcons.solidMessage,
                    bgColor: Colors.white,
                    borderColor: blueColor,
                    textIconColor: blueColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Add to favorites',
                    onPressed: () {},
                    icon: FontAwesomeIcons.solidHeart,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  provider.productData['catName'] == 'Vehicles'
                      ? Column(
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
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius: BorderRadius.circular(10),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.60,
                                        child: Text(
                                          provider.productData['brandName'],
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.60,
                                        child: Text(
                                          provider.productData['modelName'],
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
                                    height: 10,
                                    color: fadedColor,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.solidUser,
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
                                        provider.productData['noOfOwners'],
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.gasPump,
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
                                        provider.productData['fuelType'],
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.calendarDay,
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
                                        provider.productData['yearOfReg']
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.road,
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
                                          provider.productData['kmsDriven'],
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.list,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: Text(
                                          '${provider.productData['catName']} > ${provider.productData['subCat']}',
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
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.clock,
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
                              height: 20,
                            ),
                          ],
                        )
                      : Column(
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
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.list,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: Text(
                                          '${provider.productData['catName']} > ${provider.productData['subCat']}',
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
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.clock,
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
                              height: 20,
                            ),
                          ],
                        ),
                  Text(
                    'Item description from the seller',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDescExpanded = true;
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: greyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: isDescExpanded
                          ? Text(
                              provider.productData['description'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: blackColor,
                                fontSize: 15,
                              ),
                            )
                          : Text(
                              provider.productData['description'],
                              maxLines: 4,
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
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'About this seller',
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: greyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: blueColor,
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://img.icons8.com/fluency/48/000000/user-male-circle.png',
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  FontAwesomeIcons.triangleExclamation,
                                  size: 20,
                                  color: redColor,
                                );
                              },
                              placeholder: (context, url) {
                                return const Center(
                                  child: SpinKitFadingCube(
                                    color: blueColor,
                                    size: 30,
                                    duration: Duration(milliseconds: 1000),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              provider.sellerData['name'] == null
                                  ? Text(
                                      'Name not disclosed',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
                                        fontSize: 15,
                                      ),
                                    )
                                  : Text(
                                      provider.sellerData['name'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
                                        fontSize: 15,
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
                            FontAwesomeIcons.chevronRight,
                            color: blackColor,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'More like this',
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
