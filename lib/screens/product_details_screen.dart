import 'package:buy_sell_app/provider/product_provider.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
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

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              FontAwesomeIcons.share,
              color: blueColor,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          LikeButton(
            circleColor: const CircleColor(
              start: Color.fromARGB(255, 255, 0, 0),
              end: Color.fromARGB(255, 237, 34, 34),
            ),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xff33b5e5),
              dotSecondaryColor: Color(0xff0099cc),
            ),
            animationDuration: const Duration(milliseconds: 1000),
            likeBuilder: (bool isLiked) {
              return isLiked
                  ? const Icon(
                      FontAwesomeIcons.solidHeart,
                      color: Colors.red,
                      size: 20,
                    )
                  : const Icon(
                      FontAwesomeIcons.heart,
                      color: Colors.red,
                      size: 20,
                    );
            },
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              FontAwesomeIcons.ellipsis,
              color: blackColor,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 10,
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
                    return Material(
                      color: Colors.black,
                      child: Stack(
                        children: [
                          CarouselSlider.builder(
                            itemCount: images.length,
                            itemBuilder: (context, index, realIndex) {
                              return Image.network(
                                images[index],
                              );
                            },
                            options: CarouselOptions(
                              viewportFraction: 1,
                              height: MediaQuery.of(context).size.height,
                              enlargeCenterPage: true,
                              enableInfiniteScroll:
                                  images.length == 1 ? false : true,
                              reverse: false,
                              initialPage: currentImage,
                              scrollDirection: Axis.horizontal,
                              scrollPhysics: const BouncingScrollPhysics(),
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentImage = index;
                                });
                              },
                            ),
                          ),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
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
                        return Image.network(
                          images[index],
                        );
                      },
                      options: CarouselOptions(
                        viewportFraction: 1,
                        height: MediaQuery.of(context).size.height,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: images.length == 1 ? false : true,
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
                        horizontal: 5,
                        vertical: 2,
                      ),
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
                  )
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
                  margin: const EdgeInsets.only(
                    left: 2,
                    right: 2,
                    top: 10,
                    bottom: 0,
                  ),
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
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
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
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Add to favorites',
                    onPressed: () {},
                    icon: FontAwesomeIcons.solidHeart,
                    bgColor: Colors.red,
                    textIconColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Contact Seller',
                    onPressed: () {},
                    icon: FontAwesomeIcons.solidMessage,
                    bgColor: blackColor,
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
                                                0.65,
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
                                                0.65,
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
                                        FontAwesomeIcons.solidClock,
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
                      : const SizedBox(
                          height: 0,
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
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: blueColor,
                        child: Text(
                          'AB',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 15,
                          ),
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
                                  'no name',
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
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
