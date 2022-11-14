import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '/provider/seller_form_provider.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';

class EditAdScreen extends StatefulWidget {
  final DocumentSnapshot productData;
  const EditAdScreen({
    super.key,
    required this.productData,
  });

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  bool isLoading = false;

  TextEditingController categoryController = TextEditingController();
  TextEditingController subCatNameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    getConnectivity();
    categoryController.text =
        '${widget.productData['catName']} > ${widget.productData['subCat']}';
    titleController.text = widget.productData['title'];
    descriptionController.text = widget.productData['description'];
    priceController.text = widget.productData['price'].toString();
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
                top: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Connection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
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
    subscription.cancel();
    categoryController.dispose();
    subCatNameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerFormProvider>(context);

    updateProductOnFirebase(SellerFormProvider provider, String uid) async {
      return await _services.listings
          .doc(uid)
          .update(provider.updatedDataToFirestore)
          .then((_) {
        Get.back();
        provider.clearDataAfterUpdateListing();
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          content: 'Details updated. Product will be active once reviewed',
          color: blueColor,
        );
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
        showSnackBar(
          content: 'Please fill all the required fields',
          color: redColor,
        );
        return;
      }
      if (titleController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          priceController.text.isEmpty) {
        showSnackBar(
          content: 'Please fill all the required fields',
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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
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
                  const Text(
                    'Ready to update?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
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
                        Column(
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
                    text: 'Confirm & Update',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Get.back();
                      String uid = widget.productData.id;
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
                        return searchQueries;
                      }

                      provider.updatedDataToFirestore.addAll({
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'price': int.parse(priceController.text),
                        'searchQueries': setSearchParams(
                          s: titleController.text.toLowerCase(),
                          n: titleController.text.length,
                          catName: widget.productData['catName'].toLowerCase(),
                          subCatName:
                              widget.productData['subCat'].toLowerCase(),
                        ),
                        'isActive': false,
                      });
                      await updateProductOnFirebase(provider, uid);
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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
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
                  const Text(
                    'Warning',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
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
                      Get.back();
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
          leading: IconButton(
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(FontAwesomeIcons.circleXmark),
          ),
          centerTitle: true,
          title: const Text(
            'Edit your product listing',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: categoryController,
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
                    label: 'Title',
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
                    label: 'Description',
                    hint:
                        'Briefly describe your vehicle to increase your chances of getting a good deal. Include details like condition, features, reason for selling, etc.',
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
                        return 'Please enter the price for your product';
                      }
                      return null;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Price',
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
                          color: Colors.red,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      errorStyle: const TextStyle(
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
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: blueColor,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: greyColor,
                      ),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                      floatingLabelStyle: const TextStyle(
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
              ? CustomButton(
                  text: 'Loading...',
                  onPressed: () {},
                  isDisabled: isLoading,
                  icon: FontAwesomeIcons.spinner,
                  bgColor: greyColor,
                  borderColor: greyColor,
                  textIconColor: blackColor,
                )
              : CustomButton(
                  text: 'Proceed',
                  onPressed: validateForm,
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
