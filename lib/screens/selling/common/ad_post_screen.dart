import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../../../provider/providers.dart';
import '../../../widgets/loading_button.dart';
import '../../../widgets/text_field_label.dart';
import '../congratulations_screen.dart';
import '/utils/utils.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button.dart';
import '/widgets/image_picker_widget.dart';
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
  final TextEditingController subCatNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FirebaseServices _services = FirebaseServices();
  double latitude = 0;
  double longitude = 0;
  String area = '';
  String city = '';
  String state = '';
  String country = '';
  bool isLoading = false;

  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  Future<void> getUserLocation() async {
    final userData = await _services.getCurrentUserData();
    final locationData = userData['location'];
    if (mounted) {
      setState(() {
        locationController.text =
            '${locationData['area']}, ${locationData['city']}, ${locationData['state']}, ${locationData['country']}';
        area = locationData['area'];
        city = locationData['city'];
        state = locationData['state'];
        country = locationData['country'];
        latitude = locationData['latitude'];
        longitude = locationData['longitude'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    subCatNameController.text = '${widget.catName} > ${widget.subCatName}';
    getUserLocation();
  }

  showNetworkError() {
    showModalBottomSheet(
      context: context,
      backgroundColor: transparentColor,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: whiteColor,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                left: 15,
                right: 15,
                top: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Network Connection Lost',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Image.asset(
                    'assets/no-network.png',
                    fit: BoxFit.contain,
                    semanticLabel: 'no network connection',
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: greyColor,
                    ),
                    child: Text(
                      'Please check your internet connection',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.interTight(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Re-Connect',
                    onPressed: () async {
                      Get.back();
                      setState(() {
                        isAlertSet = false;
                      });
                      isDeviceConnected =
                          await InternetConnectionChecker().hasConnection;
                      if (!isDeviceConnected) {
                        showNetworkError();
                        setState(() {
                          isAlertSet = true;
                        });
                      }
                    },
                    borderColor: redColor,
                    bgColor: redColor,
                    textIconColor: whiteColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getConnectivity() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && !isAlertSet) {
        showNetworkError();
        setState(() => isAlertSet = true);
      }
    });
  }

  @override
  void dispose() {
    subCatNameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<SellerFormProvider>(context);

    publishProductToFirebase(SellerFormProvider provider) async {
      try {
        await _services.listings.doc().set(provider.dataToFirestore);
        Get.off(
          () => const CongratulationsScreen(),
        );
        provider.clearDataAfterSubmitListing();
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } on FirebaseException {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    validateForm() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      if (titleController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          priceController.text.isEmpty) {
        return;
      }
      if (provider.imagePaths.isEmpty) {
        showSnackBar(
          content: 'Please upload some images of the product',
          color: redColor,
        );
        return;
      }
      showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        backgroundColor: transparentColor,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: whiteColor,
              ),
              padding: const EdgeInsets.only(
                left: 15,
                top: 5,
                right: 15,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 80.0,
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
                  Center(
                    child: Text(
                      'Ready to post?',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                                    SizedBox(
                                      width: size.width * 0.2,
                                      height: size.width * 0.2,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.file(
                                          provider.imagePaths[0],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Ionicons.alert_circle_outline,
                                              size: 20,
                                              color: redColor,
                                            );
                                          },
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
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 30,
                                              color: whiteColor,
                                              shadows: [
                                                const Shadow(
                                                  offset: Offset(0, 2),
                                                  blurRadius: 10.0,
                                                  color: lightBlackColor,
                                                ),
                                              ],
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
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
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
                                      style: GoogleFonts.interTight(
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
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButtonWithoutIcon(
                          text: 'Cancel',
                          onPressed: () => Get.back(),
                          bgColor: whiteColor,
                          borderColor: greyColor,
                          textIconColor: blackColor,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: CustomButton(
                          text: 'Post',
                          icon: Ionicons.checkmark_outline,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Get.back();
                            List<String?> urls =
                                await provider.uploadFiles(provider.imagePaths);
                            if (urls.contains('')) {
                              showSnackBar(
                                content:
                                    'Something has gone wrong. Please try again',
                                color: redColor,
                              );
                              return;
                            }
                            var time = DateTime.now().millisecondsSinceEpoch;
                            List<String> setSearchParams({
                              required String s,
                              required int n,
                              required String catName,
                              required String subCatName,
                            }) {
                              List<String> searchQueries = [];
                              for (int i = 0; i < n; i++) {
                                for (int j = i + 2; j < n; j++) {
                                  searchQueries.add(s.substring(i, j + 1));
                                }
                              }
                              for (int i = 0; i < catName.length; i++) {
                                for (int j = i + 2; j < catName.length; j++) {
                                  searchQueries
                                      .add(catName.substring(i, j + 1));
                                }
                              }
                              for (int i = 0; i < subCatName.length; i++) {
                                for (int j = i + 2;
                                    j < subCatName.length;
                                    j++) {
                                  searchQueries
                                      .add(subCatName.substring(i, j + 1));
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
                              'postedAt': time,
                              'favorites': [],
                              'views': [],
                              'searchQueries': setSearchParams(
                                s: titleController.text.toLowerCase(),
                                n: titleController.text.length,
                                catName: widget.catName.toLowerCase(),
                                subCatName: widget.subCatName.toLowerCase(),
                              ),
                              'location': {
                                'latitude': latitude,
                                'longitude': longitude,
                                'area': area,
                                'city': city,
                                'state': state,
                                'country': country,
                              },
                              'isSold': false,
                              'isActive': false,
                              'isRejected': false,
                              'isShowedInConsole': true,
                            });
                            publishProductToFirebase(provider);
                          },
                          bgColor: blueColor,
                          borderColor: blueColor,
                          textIconColor: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    resetAll() {
      showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        backgroundColor: transparentColor,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: whiteColor,
              ),
              padding: const EdgeInsets.only(
                left: 15,
                top: 5,
                right: 15,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 80.0,
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
                  Center(
                    child: Text(
                      'Are you sure?',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: greyColor,
                    ),
                    child: Text(
                      'All your product details will be removed and you\'ll have to start fresh.',
                      style: GoogleFonts.interTight(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButtonWithoutIcon(
                          text: 'No, Cancel',
                          onPressed: () => Get.back(),
                          bgColor: whiteColor,
                          borderColor: greyColor,
                          textIconColor: blackColor,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: CustomButtonWithoutIcon(
                          text: 'Yes, Reset All',
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
                          bgColor: whiteColor,
                          borderColor: redColor,
                          textIconColor: redColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    closePageAndGoToHome() {
      showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        backgroundColor: transparentColor,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: whiteColor,
              ),
              padding: const EdgeInsets.only(
                left: 15,
                top: 5,
                right: 15,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 80.0,
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
                  Center(
                    child: Text(
                      'Warning',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: greyColor,
                    ),
                    child: Text(
                      'Are you sure you want to leave? Your progress will not be saved.',
                      style: GoogleFonts.interTight(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButtonWithoutIcon(
                          text: 'No, Stay Here',
                          onPressed: () => Get.back(),
                          bgColor: whiteColor,
                          borderColor: greyColor,
                          textIconColor: blackColor,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: CustomButtonWithoutIcon(
                          text: 'Yes, Leave',
                          onPressed: () {
                            setState(() {
                              titleController.text = '';
                              descriptionController.text = '';
                              priceController.text = '';
                              provider.imagePaths.clear();
                              provider.clearImagesCount();
                            });
                            Get.offAll(
                                () => const MainScreen(selectedIndex: 0));
                          },
                          bgColor: whiteColor,
                          borderColor: redColor,
                          textIconColor: redColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        backgroundColor: whiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.2,
          backgroundColor: whiteColor,
          iconTheme: const IconThemeData(color: blackColor),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => closePageAndGoToHome(),
            enableFeedback: true,
            icon: const Icon(Ionicons.close_circle_outline),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : resetAll,
              child: Text(
                'Reset all',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: redColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          title: Text(
            'Create your product listing',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 15,
            ),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  color: blackColor,
                  child: Text(
                    'Step 1 - User Details',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.interTight(
                      color: whiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Location'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: locationController,
                    keyboardType: TextInputType.text,
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
                    'Location can be changed from Settings > Change Location',
                    style: GoogleFonts.interTight(
                      color: lightBlackColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  color: blackColor,
                  child: Text(
                    'Step 2 - Product Details',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.interTight(
                      color: whiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Category'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: subCatNameController,
                    keyboardType: TextInputType.text,
                    hint: '',
                    isEnabled: false,
                    maxLength: 150,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Product Title'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: titleController,
                    keyboardType: TextInputType.text,
                    hint: 'Mention key features of your item',
                    maxLength: 35,
                    textInputAction: TextInputAction.next,
                    showCounterText: true,
                    isEnabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      if (value.length < 5) {
                        return 'Please enter 5 or more characters';
                      }
                      setState(() {});
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Description'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    hint:
                        'Briefly describe your product to increase your chances of getting a good deal.\nInclude details like condition, features, reason for selling, etc.',
                    maxLength: 300,
                    maxLines: 5,
                    showCounterText: true,
                    isEnabled: isLoading ? false : true,
                    textInputAction: TextInputAction.newline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 20) {
                        return 'Please enter 20 or more characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Price'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: priceController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
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
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Set a price for your product',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      counterText: '',
                      fillColor: greyColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: transparentColor,
                          width: 0,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: transparentColor,
                          width: 0,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: redColor,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      errorStyle: GoogleFonts.interTight(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: redColor,
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
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintStyle: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: fadedColor,
                      ),
                      labelStyle: GoogleFonts.interTight(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  color: blackColor,
                  child: Text(
                    'Step 3 - Product Images',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.interTight(
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
              ],
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
              ? const LoadingButton(
                  bgColor: blueColor,
                )
              : CustomButton(
                  text: 'Proceed',
                  onPressed: () => validateForm(),
                  icon: Ionicons.arrow_forward,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
        ),
      ),
    );
  }
}
