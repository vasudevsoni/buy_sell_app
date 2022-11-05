import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';
import '../provider/seller_form_provider.dart';
import '../utils/utils.dart';

// ignore: must_be_immutable
class ImagePickerWidget extends StatefulWidget {
  static const String routeName = '/image-picker-screen';
  bool isButtonDisabled;
  ImagePickerWidget({
    super.key,
    this.isButtonDisabled = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerFormProvider>(context);

    showMaximumError() {
      showSnackBar(
        context: context,
        content: 'Maximum 15 images are allowed.',
        color: redColor,
      );
    }

    Future getImageFromCamera() async {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
      if (pickedFile == null) {
        return null;
      } else {
        provider.addImageToPaths(File(pickedFile.path));
      }
      provider.imagesCount += 1;
      setState(() {});
    }

    Future getImageFromGallery() async {
      final List<XFile>? pickedFiles =
          await picker.pickMultiImage(imageQuality: 100);
      if (pickedFiles!.isEmpty) {
        return null;
      } else if (pickedFiles.length > 15) {
        showMaximumError();
        return null;
      } else {
        for (var i in pickedFiles) {
          provider.addImageToPaths(File(i.path));
        }
      }
      provider.imagesCount += pickedFiles.length;
      setState(() {});
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              provider.imagePaths.isNotEmpty
                  ? GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemCount: provider.imagePaths.length,
                      itemBuilder: (context, index) {
                        PageController pageController =
                            PageController(initialPage: index);
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Opacity(
                                opacity: 0.7,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    showModal(
                                      configuration:
                                          const FadeScaleTransitionConfiguration(),
                                      context: context,
                                      builder: (context) {
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
                                                  itemCount: provider
                                                      .imagePaths.length,
                                                  pageController:
                                                      pageController,
                                                  builder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return PhotoViewGalleryPageOptions(
                                                      imageProvider: FileImage(
                                                        provider
                                                            .imagePaths[index],
                                                      ),
                                                      filterQuality:
                                                          FilterQuality.high,
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
                                                              5,
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
                                                    return const Icon(
                                                      FontAwesomeIcons
                                                          .solidImage,
                                                      size: 20,
                                                      color: lightBlackColor,
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
                                                    splashColor: Colors.blue,
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
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      provider.imagePaths[index],
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          FontAwesomeIcons.circleExclamation,
                                          size: 20,
                                          color: redColor,
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                left: -10,
                                child: IconButton(
                                  tooltip: 'Delete image',
                                  onPressed: () {
                                    widget.isButtonDisabled
                                        ? null
                                        : setState(() {
                                            provider.imagePaths.removeAt(index);
                                            provider.imagesCount -= 1;
                                          });
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.circleXmark,
                                    size: 15,
                                    color: whiteColor,
                                    shadows: [
                                      BoxShadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 5,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Uploaded pics will show here.',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
              if (provider.imagePaths.isNotEmpty)
                Text(
                  '${provider.imagePaths.length} / 15',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: fadedColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CustomButton(
            text: 'Take Photo',
            onPressed: provider.imagesCount >= 15
                ? showMaximumError
                : getImageFromCamera,
            icon: FontAwesomeIcons.cameraRetro,
            bgColor: blackColor,
            borderColor: blackColor,
            textIconColor: whiteColor,
            isDisabled: widget.isButtonDisabled,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CustomButton(
            text: 'Choose Photos',
            onPressed: provider.imagesCount >= 15
                ? showMaximumError
                : getImageFromGallery,
            icon: FontAwesomeIcons.solidImages,
            bgColor: whiteColor,
            borderColor: greyColor,
            textIconColor: blackColor,
            isDisabled: widget.isButtonDisabled,
          ),
        ),
      ],
    );
  }
}
