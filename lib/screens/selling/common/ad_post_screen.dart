import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../../../widgets/loading_button.dart';
import '../../../widgets/text_field_label.dart';
import '/screens/selling/congratulations_screen.dart';
import '/provider/seller_form_provider.dart';
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
  bool isLoading = false;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

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
      getConnectivity();
      setState(() {
        subCatNameController.text = '${widget.catName} > ${widget.subCatName}';
      });
      getUserLocation();
    }
    super.initState();
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
                top: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'No Connection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: greyColor,
                    ),
                    child: const Text(
                      'Please check your internet connection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'OK',
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

  getConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && isAlertSet == false) {
        showNetworkError();
        setState(() {
          isAlertSet = true;
        });
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
    final provider = Provider.of<SellerFormProvider>(context);

    publishProductToFirebase(SellerFormProvider provider) async {
      return await _services.listings
          .doc()
          .set(provider.dataToFirestore)
          .then((value) {
        Get.off(
          () => const CongratulationsScreen(),
        );
        provider.clearDataAfterSubmitListing();
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
        setState(() {
          isLoading = false;
        });
      });
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
                  const Center(
                    child: Text(
                      'Ready to post?',
                      style: TextStyle(
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
                                    Opacity(
                                      opacity: 0.7,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.file(
                                            provider.imagePaths[0],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Ionicons.alert_circle,
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
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 30,
                                              color: whiteColor,
                                              shadows: [
                                                Shadow(
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
                                      style: const TextStyle(
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
                                      style: const TextStyle(
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
                          style: const TextStyle(
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
                  CustomButtonWithoutIcon(
                    text: 'Confirm & Post',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Get.back();
                      List<String> urls =
                          await provider.uploadFiles(provider.imagePaths);
                      var time = DateTime.now().millisecondsSinceEpoch;
                      setSearchParams({
                        required String s,
                        required int n,
                        required String catName,
                        required String subCatName,
                      }) {
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
                        for (int i = 0; i < catName.length; i++) {
                          String catNameTemp = '';
                          for (int j = i; j < catName.length; j++) {
                            catNameTemp += catName[j];
                            if (catNameTemp.length >= 3) {
                              searchQueries.add(catNameTemp);
                            }
                          }
                        }
                        for (int i = 0; i < subCatName.length; i++) {
                          String subCatNameTemp = '';
                          for (int j = i; j < subCatName.length; j++) {
                            subCatNameTemp += subCatName[j];
                            if (subCatNameTemp.length >= 3) {
                              searchQueries.add(subCatNameTemp);
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
                          'area': area,
                          'city': city,
                          'state': state,
                          'country': country,
                        },
                        'isSold': false,
                        'isActive': false,
                      });
                      publishProductToFirebase(provider);
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
                    onPressed: () => Get.back(),
                    bgColor: whiteColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
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
                  const Center(
                    child: Text(
                      'Are you sure?',
                      style: TextStyle(
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
                    child: const Text(
                      'All your product details will be removed and you\'ll have to start fresh.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
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
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'No, Cancel',
                    onPressed: () => Get.back(),
                    bgColor: whiteColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
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
                  const Center(
                    child: Text(
                      'Warning',
                      style: TextStyle(
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
                    child: const Text(
                      'Are you sure you want to leave? Your progress will not be saved.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Yes, Leave',
                    onPressed: () {
                      setState(() {
                        titleController.text = '';
                        descriptionController.text = '';
                        priceController.text = '';
                        provider.imagePaths.clear();
                        provider.clearImagesCount();
                      });
                      Get.offAll(() => const MainScreen(selectedIndex: 0));
                    },
                    bgColor: whiteColor,
                    borderColor: redColor,
                    textIconColor: redColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'No, Stay Here',
                    onPressed: () => Get.back(),
                    bgColor: whiteColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.5,
          backgroundColor: whiteColor,
          iconTheme: const IconThemeData(color: blackColor),
          centerTitle: true,
          leading: IconButton(
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(Ionicons.close_circle_outline),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : resetAll,
              child: const Text(
                'Reset all',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: redColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          title: const Text(
            'Create your product listing',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: blackColor,
              fontSize: 15,
            ),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blackColor,
                  child: const Text(
                    'Step 1 - Product Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                    maxLength: 80,
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
                    hint: 'Sony PlayStation 5 in good codition',
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
                    style: const TextStyle(
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
                      errorStyle: const TextStyle(
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
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: fadedColor,
                      ),
                      labelStyle: const TextStyle(
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
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blackColor,
                  child: const Text(
                    'Step 2 - Product Images',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                  color: blackColor,
                  child: const Text(
                    'Step 3 - User Location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'To change your location go to settings.',
                    style: TextStyle(
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
        bottomNavigationBar: Container(
          color: greyColor,
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
            top: 10,
          ),
          child: isLoading
              ? const LoadingButton()
              : CustomButton(
                  text: 'Proceed',
                  onPressed: validateForm,
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
