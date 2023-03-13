import 'dart:io';

import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';
import '/provider/seller_form_provider.dart';
import '/utils/utils.dart';

class ImagePickerWidget extends StatefulWidget {
  final bool isButtonDisabled;

  const ImagePickerWidget({
    super.key,
    this.isButtonDisabled = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker picker = ImagePicker();
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerFormProvider>(context);

    showMaximumError() {
      showSnackBar(
        content: 'Maximum 12 images are allowed',
        color: redColor,
      );
    }

    Future getImageFromCamera() async {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null && mounted) {
        final compressedImage =
            await _services.compressImage(File(pickedFile.path));
        if (compressedImage.lengthSync() >= 2000000) {
          showSnackBar(
              color: redColor, content: 'Maximum image size allowed is 2MB');
        } else {
          provider.addImageToPaths(compressedImage);
        }
      }
    }

    Future getImageFromGallery() async {
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isEmpty) {
        return;
      }
      if (pickedFiles.length > 12) {
        showMaximumError();
        return;
      }
      for (var i in pickedFiles) {
        final compressedImage = await _services.compressImage(File(i.path));
        if (compressedImage.lengthSync() >= 2000000) {
          showSnackBar(
              color: redColor, content: 'Maximum image size allowed is 2MB');
        } else {
          await provider.addImageToPaths(compressedImage);
        }
      }
    }

    void requestCameraPermission() async {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        await getImageFromCamera();
      } else if (status.isDenied) {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          await getImageFromCamera();
        } else {
          showSnackBar(
            content: 'Camera permission is required to take pictures',
            color: redColor,
          );
        }
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        showSnackBar(
          content: 'Permission is disabled. Please change from phone settings',
          color: redColor,
        );
        openAppSettings();
      }
    }

    void requestGalleryPermission() async {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        await getImageFromGallery();
      } else if (status.isDenied || status.isLimited) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          await getImageFromGallery();
        } else {
          showSnackBar(
            content: 'Storage permission is required to upload pictures',
            color: redColor,
          );
        }
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        showSnackBar(
          content: 'Permission is disabled. Please change from phone settings',
          color: redColor,
        );
        openAppSettings();
      }
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: greyColor,
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
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) {
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
                                              itemCount:
                                                  provider.imagePaths.length,
                                              pageController: pageController,
                                              builder: (BuildContext context,
                                                  int index) {
                                                return PhotoViewGalleryPageOptions(
                                                  imageProvider: FileImage(
                                                    provider.imagePaths[index],
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
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                      MdiIcons.alertDecagram,
                                                      size: 20,
                                                      color: redColor,
                                                    );
                                                  },
                                                );
                                              },
                                              loadingBuilder: (context, event) {
                                                return const Icon(
                                                  MdiIcons.imageFilterHdr,
                                                  size: 20,
                                                  color: lightBlackColor,
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
                                                icon: const Icon(
                                                  MdiIcons.closeCircle,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    provider.imagePaths[index],
                                    cacheHeight:
                                        (MediaQuery.of(context).size.height *
                                                0.3)
                                            .round(),
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        MdiIcons.alertDecagram,
                                        size: 20,
                                        color: redColor,
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index == 0 ? blueColor : fadedColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    index == 0 ? 'Cover' : '${index + 1}',
                                    style: GoogleFonts.interTight(
                                      color: whiteColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Tooltip(
                                  message: 'Delete image',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => setState(() {
                                      provider.removeImageFromPaths(index);
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: redColor,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: const Icon(
                                        MdiIcons.close,
                                        size: 18,
                                        color: whiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: greyColor,
                      ),
                      height: 100,
                      child: Center(
                        child: Text(
                          'Upload some pictures',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.interTight(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
              if (provider.imagePaths.isNotEmpty)
                Text(
                  '${provider.imagePaths.length} / 12',
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w500,
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Take Photo',
                  onPressed: provider.imagesCount >= 12
                      ? showMaximumError
                      : requestCameraPermission,
                  icon: MdiIcons.camera,
                  bgColor: whiteColor,
                  borderColor: blackColor,
                  textIconColor: blackColor,
                  isDisabled: widget.isButtonDisabled,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomButton(
                  text: 'Upload',
                  onPressed: provider.imagesCount >= 12
                      ? showMaximumError
                      : requestGalleryPermission,
                  icon: MdiIcons.imagePlus,
                  bgColor: whiteColor,
                  borderColor: blackColor,
                  textIconColor: blackColor,
                  isDisabled: widget.isButtonDisabled,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
