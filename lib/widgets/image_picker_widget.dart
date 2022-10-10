import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

    Future getImageFromCamera() async {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (File(pickedFile!.path) != null) {
        provider.addToImagePaths(File(pickedFile.path));
        provider.imagesCount += 1;
        setState(() {});
      }
    }

    Future getImageFromGallery() async {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (File(pickedFile!.path) != null) {
        provider.addToImagePaths(File(pickedFile.path));
        provider.imagesCount += 1;
        setState(() {});
      }
    }

    showMaximumError() {
      showSnackBar(context: context, content: 'Maximum images allowed is 15');
    }

    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          provider.imagePaths.isNotEmpty
              ? GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: provider.imagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Stack(
                        fit: StackFit.expand,
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
                                        CarouselSlider(
                                          items: provider.imagePaths
                                              .map(
                                                (item) => Image.file(
                                                  item,
                                                ),
                                              )
                                              .toList(),
                                          options: CarouselOptions(
                                            viewportFraction: 1,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            enlargeCenterPage: true,
                                            initialPage: index,
                                            enableInfiniteScroll: false,
                                            reverse: false,
                                            scrollDirection: Axis.horizontal,
                                            scrollPhysics:
                                                const BouncingScrollPhysics(),
                                          ),
                                        ),
                                        Positioned(
                                          top: 15,
                                          right: 15,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            splashColor: Colors.blue,
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                provider.imagePaths[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
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
                                FontAwesomeIcons.xmark,
                                size: 14,
                                color: Colors.white,
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
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        'Uploaded pics will show here.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.imagePaths.length} / 15',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: fadedColor,
                  fontSize: 12,
                ),
              ),
              Text(
                'Max 15 images allowed',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: fadedColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomButton(
            text: 'Choose from Gallery',
            onPressed: provider.imagesCount >= 15
                ? showMaximumError
                : getImageFromGallery,
            icon: FontAwesomeIcons.images,
            bgColor: blueColor,
            textIconColor: Colors.white,
            isDisabled: widget.isButtonDisabled,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomButton(
            text: 'Choose from Camera',
            onPressed: provider.imagesCount >= 15
                ? showMaximumError
                : getImageFromCamera,
            icon: FontAwesomeIcons.camera,
            bgColor: Colors.white,
            textIconColor: blueColor,
            isDisabled: widget.isButtonDisabled,
          ),
        ],
      ),
    );
  }
}
