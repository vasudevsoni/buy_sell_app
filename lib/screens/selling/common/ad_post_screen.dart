import 'package:animations/animations.dart';
import 'package:buy_sell_app/screens/selling/congratulations_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../provider/seller_form_provider.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button_without_icon.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../services/firebase_services.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/image_picker_widget.dart';
import '../../main_screen.dart';

class AdPostScreen extends StatefulWidget {
  final String catName;
  final String subCatName;
  const AdPostScreen({
    super.key,
    required this.catName,
    required this.subCatName,
  });

  @override
  State<AdPostScreen> createState() => _AdPostScreenState();
}

class _AdPostScreenState extends State<AdPostScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController subCatNameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final FirebaseServices _services = FirebaseServices();
  String area = '';
  String city = '';
  String state = '';
  String country = '';

  var priceFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '₹',
    name: '',
  );
  bool isLoading = false;

  getUserLocation() async {
    await _services.getCurrentUserData().then((value) async {
      setState(() {
        locationController.text =
            '${value['location']['area']}, ${value['location']['city']}, ${value['location']['state']}, ${value['location']['country']}';
        area = value['location']['area'];
        city = value['location']['city'];
        state = value['location']['state'];
        country = value['location']['country'];
      });
    });
  }

  @override
  void initState() {
    if (mounted) {
      setState(() {
        subCatNameController.text = '${widget.catName} > ${widget.subCatName}';
      });
      getUserLocation();
    }
    super.initState();
  }

  @override
  void dispose() {
    subCatNameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerFormProvider>(context);

    publishProductToFirebase(SellerFormProvider provider, String uid) async {
      return await _services.listings
          .doc(uid)
          .set(provider.dataToFirestore)
          .then((value) {
        Navigator.pushReplacementNamed(
            context, CongratulationsScreen.routeName);
        provider.clearDataAfterSubmitListing();
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        showSnackBar(
          context: context,
          content: 'Something has gone wrong. Please try again.',
          color: redColor,
        );
        setState(() {
          isLoading = false;
        });
      });
    }

    validateForm() async {
      if (_formKey.currentState!.validate()) {
        if (titleController.text.isNotEmpty &&
            descriptionController.text.isNotEmpty &&
            priceController.text.isNotEmpty &&
            provider.imagePaths.isNotEmpty) {
          showModal(
            configuration: const FadeScaleTransitionConfiguration(),
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Ready to post?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: greyColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Opacity(
                                    opacity: 0.7,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.file(
                                          provider.imagePaths[0],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              FontAwesomeIcons
                                                  .circleExclamation,
                                              size: 20,
                                              color: redColor,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (provider.imagePaths.length >= 2)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: Text(
                                          '+${(provider.imagesCount - 1).toString()}',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 30,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titleController.text,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    priceFormat.format(
                                      int.parse(priceController.text),
                                    ),
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: blueColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        color: lightBlackColor,
                      ),
                      Text(
                        'Description - ${descriptionController.text}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: blackColor,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                titlePadding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 15,
                  bottom: 10,
                ),
                contentPadding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 5,
                  top: 5,
                ),
                actions: [
                  CustomButtonWithoutIcon(
                    text: 'Confirm & Post',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Get.back();
                      List<String> urls =
                          await provider.uploadFiles(provider.imagePaths);
                      var uid = DateTime.now().millisecondsSinceEpoch;
                      setSearchParams(String s, int n) {
                        List<String> searchQueries = [];
                        for (int i = 0; i < n; i++) {
                          String temp = '';
                          for (int j = i; j < n; j++) {
                            temp += s[j];
                            if (temp.length >= 3) {
                              searchQueries.add(temp);
                            }
                          }
                        }
                        return searchQueries;
                      }

                      provider.dataToFirestore.addAll({
                        'catName': widget.catName,
                        'subCat': widget.subCatName,
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'price': int.parse(priceController.text),
                        'sellerUid': _services.user!.uid,
                        'images': urls,
                        'postedAt': uid,
                        'favorites': [],
                        'views': [],
                        'searchQueries': setSearchParams(
                          titleController.text.toLowerCase(),
                          titleController.text.length,
                        ),
                        'location': {
                          'area': area,
                          'city': city,
                          'state': state,
                          'country': country,
                        },
                        'isActive': false,
                      });
                      publishProductToFirebase(provider, uid.toString());
                    },
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Go Back & Check',
                    onPressed: () {
                      Get.back();
                    },
                    bgColor: whiteColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
                  ),
                ],
              );
            },
          );
        }
        if (provider.imagePaths.isEmpty) {
          showSnackBar(
            context: context,
            content: 'Please upload some images of the product.',
            color: redColor,
          );
        }
      }
    }

    resetAll() {
      showModal(
        configuration: const FadeScaleTransitionConfiguration(),
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Are you sure?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            content: Container(
              padding: const EdgeInsets.all(15),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: greyColor,
              ),
              child: Text(
                'All your listing details will be removed and you\'ll have to start fresh.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            titlePadding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 10,
            ),
            contentPadding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 5,
              top: 5,
            ),
            actions: [
              CustomButtonWithoutIcon(
                text: 'Yes, Reset all',
                onPressed: () {
                  setState(() {
                    titleController.text = '';
                    descriptionController.text = '';
                    priceController.text = '';
                    provider.imagePaths.clear();
                    provider.clearImagesCount();
                  });
                  Get.back();
                },
                bgColor: redColor,
                borderColor: redColor,
                textIconColor: whiteColor,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButtonWithoutIcon(
                text: 'No, Cancel',
                onPressed: () {
                  Get.back();
                },
                bgColor: whiteColor,
                borderColor: greyColor,
                textIconColor: blackColor,
              ),
            ],
          );
        },
      );
    }

    closePageAndGoToHome() {
      showModal(
        configuration: const FadeScaleTransitionConfiguration(),
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Warning',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            content: Container(
              padding: const EdgeInsets.all(15),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: greyColor,
              ),
              child: Text(
                'Are you sure you want to leave? Your progress will not be saved.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            titlePadding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 10,
            ),
            contentPadding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 5,
              top: 5,
            ),
            actions: [
              CustomButtonWithoutIcon(
                text: 'Yes, Leave',
                onPressed: () {
                  setState(() {
                    descriptionController.text = '';
                    priceController.text = '';
                    provider.imagePaths.clear();
                    provider.clearImagesCount();
                  });
                  Get.offAll(() => const MainScreen(
                        selectedIndex: 0,
                      ));
                },
                bgColor: redColor,
                borderColor: redColor,
                textIconColor: whiteColor,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButtonWithoutIcon(
                text: 'No, Stay here',
                onPressed: () {
                  Get.back();
                },
                bgColor: whiteColor,
                borderColor: greyColor,
                textIconColor: blackColor,
              ),
            ],
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        closePageAndGoToHome();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.5,
          backgroundColor: whiteColor,
          iconTheme: const IconThemeData(color: blackColor),
          centerTitle: true,
          leading: IconButton(
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(FontAwesomeIcons.circleXmark),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : resetAll,
              child: Text(
                'Reset All',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: redColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          title: Text(
            'Create your listing',
            style: GoogleFonts.poppins(
              color: blackColor,
              fontSize: 15,
            ),
          ),
        ),
        body: Scrollbar(
          interactive: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    color: blueColor,
                    child: Text(
                      'Step 1 - Listing Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: whiteColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextField(
                      controller: subCatNameController,
                      keyboardType: TextInputType.text,
                      label: 'Category',
                      hint: '',
                      isEnabled: false,
                      maxLength: 80,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      label: 'Title*',
                      hint: 'Enter the title',
                      maxLength: 40,
                      textInputAction: TextInputAction.next,
                      showCounterText: true,
                      isEnabled: isLoading ? false : true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.length < 10) {
                          return 'Please enter 10 or more characters';
                        }
                        setState(() {});
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextField(
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      label: 'Description*',
                      hint:
                          'Briefly describe your product to increase your chances of getting a good deal. Include details like condition, features, reason for selling, etc.',
                      maxLength: 3000,
                      maxLines: 5,
                      showCounterText: true,
                      isEnabled: isLoading ? false : true,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 30) {
                          return 'Please enter 30 or more characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: priceController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      enabled: isLoading ? false : true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the price';
                        }
                        return null;
                      },
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price*',
                        hintText: 'Set a price for your listing',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        counterText: '',
                        fillColor: greyColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: greyColor,
                        ),
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        floatingLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: lightBlackColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    color: blueColor,
                    child: Text(
                      'Step 2 - Product Images',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: whiteColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ImagePickerWidget(
                    isButtonDisabled: isLoading ? true : false,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    color: blueColor,
                    child: Text(
                      'Step 3 - User Location',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: whiteColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextField(
                      controller: locationController,
                      keyboardType: TextInputType.text,
                      label: 'Location*',
                      hint: 'Choose your location to list product',
                      maxLines: 2,
                      showCounterText: false,
                      isEnabled: false,
                      textInputAction: TextInputAction.go,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'To change your location go to settings.',
                      style: GoogleFonts.poppins(
                        color: lightBlackColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: greyColor,
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
            top: 10,
          ),
          child: isLoading
              ? CustomButton(
                  text: 'Loading..',
                  onPressed: () {},
                  isDisabled: isLoading,
                  icon: FontAwesomeIcons.spinner,
                  bgColor: greyColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                )
              : CustomButton(
                  text: 'Proceed',
                  onPressed: () {
                    validateForm();
                  },
                  icon: FontAwesomeIcons.arrowRight,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
        ),
      ),
    );
  }
}
