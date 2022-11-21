import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/utils/utils.dart';

class AllImagesDisplayScreen extends StatelessWidget {
  final List images;
  const AllImagesDisplayScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: const Text(
          'Product images',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 15,
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
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) {
                        PageController pageController =
                            PageController(initialPage: index);
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                    child: SizedBox(
                      height: size.height * 0.3,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Ionicons.alert_circle,
                              size: 30,
                              color: redColor,
                            );
                          },
                          placeholder: (context, url) {
                            return const Center(
                              child: SpinKitFadingCircle(
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
                    bottom: 10,
                    right: 15,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 35,
                        shadows: [
                          Shadow(
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
    );
  }
}
