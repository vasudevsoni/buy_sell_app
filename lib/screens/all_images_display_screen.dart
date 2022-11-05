import 'package:animations/animations.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllImagesDisplayScreen extends StatelessWidget {
  final List images;
  const AllImagesDisplayScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          images.length == 1 ? 'Images' : '${images.length} Images',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          interactive: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: images.length,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showModal(
                          configuration:
                              const FadeScaleTransitionConfiguration(),
                          context: context,
                          builder: (context) {
                            PageController pageController =
                                PageController(initialPage: index);
                            return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.down,
                              onDismissed: (direction) {
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
                                      builder:
                                          (BuildContext context, int index) {
                                        return PhotoViewGalleryPageOptions(
                                          imageProvider: NetworkImage(
                                            images[index],
                                          ),
                                          initialScale:
                                              PhotoViewComputedScale.contained *
                                                  1,
                                          minScale:
                                              PhotoViewComputedScale.contained *
                                                  1,
                                          maxScale:
                                              PhotoViewComputedScale.contained *
                                                  10,
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                                          child: SpinKitFadingCube(
                                            color: greyColor,
                                            size: 20,
                                            duration:
                                                Duration(milliseconds: 1000),
                                          ),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      top: 15,
                                      left: 15,
                                      child: IconButton(
                                        onPressed: () {
                                          Get.back();
                                          pageController.dispose();
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
                        );
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return const Icon(
                                FontAwesomeIcons.circleExclamation,
                                size: 30,
                                color: redColor,
                              );
                            },
                            placeholder: (context, url) {
                              return const Center(
                                child: SpinKitFadingCube(
                                  color: lightBlackColor,
                                  size: 30,
                                  duration: Duration(milliseconds: 1000),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 15,
                      child: Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 10.0,
                              color: lightBlackColor,
                            ),
                          ],
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ],
                );
              },
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
    );
  }
}
