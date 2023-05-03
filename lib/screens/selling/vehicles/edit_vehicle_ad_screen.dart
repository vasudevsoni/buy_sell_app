import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../provider/providers.dart';
import '../../../widgets/loading_button.dart';
import '../../../widgets/text_field_label.dart';
import '../utils/selling_utils.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_button_without_icon.dart';
import '/widgets/custom_text_field.dart';

class EditVehicleAdScreen extends StatefulWidget {
  final DocumentSnapshot productData;
  const EditVehicleAdScreen({
    super.key,
    required this.productData,
  });

  @override
  State<EditVehicleAdScreen> createState() => _EditVehicleAdScreenState();
}

class _EditVehicleAdScreenState extends State<EditVehicleAdScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  bool isLoading = false;

  final TextEditingController subCatNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController kmDrivenController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  dynamic fuelTypeSelectedValue;
  dynamic yorSelectedValue;
  dynamic noOfOwnersSelectedValue;
  dynamic colorSelectedValue;

  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    getConnectivity();
    subCatNameController.text = 'Vehicles > ${widget.productData['subCat']}';
    brandNameController.text = widget.productData['brandName'];
    modelNameController.text = widget.productData['modelName'];
    descriptionController.text = widget.productData['description'];
    priceController.text = widget.productData['price'].toString();
    kmDrivenController.text = widget.productData['kmsDriven'].toString();
    fuelTypeSelectedValue = widget.productData['fuelType'];
    yorSelectedValue = widget.productData['yearOfReg'].toString();
    noOfOwnersSelectedValue = widget.productData['noOfOwners'];
    colorSelectedValue = widget.productData['color'];
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
    await for (final _ in Connectivity().onConnectivityChanged) {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && !isAlertSet) {
        showNetworkError();
        setState(() => isAlertSet = true);
      }
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    titleController.dispose();
    subCatNameController.dispose();
    brandNameController.dispose();
    modelNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    kmDrivenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<SellerFormProvider>(context);

    updateProductOnFirebase(SellerFormProvider provider, String uid) async {
      try {
        await _services.listings
            .doc(uid)
            .update(provider.updatedDataToFirestore)
            .then((_) {
          Get.back();
          provider.clearDataAfterUpdateListing();
          setState(() {
            isLoading = false;
          });
          showSnackBar(
            content: 'Details updated. Product will be live once reviewed',
            color: blueColor,
          );
        });
      } on FirebaseException {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
        setState(() {
          isLoading = false;
        });
      }
    }

    validateForm() async {
      if (!_formKey.currentState!.validate()) {
        showSnackBar(
          content: 'Please fill all the required fields',
          color: redColor,
        );
        return;
      }
      if (brandNameController.text.isEmpty ||
          modelNameController.text.isEmpty ||
          fuelTypeSelectedValue == null ||
          yorSelectedValue == null ||
          noOfOwnersSelectedValue == null ||
          descriptionController.text.isEmpty ||
          priceController.text.isEmpty ||
          kmDrivenController.text.isEmpty ||
          colorSelectedValue == null) {
        showSnackBar(
          content: 'Please fill all the required fields',
          color: redColor,
        );
        return;
      }
      showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: context,
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
                      'Ready to update?',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$yorSelectedValue ${brandNameController.text} ${modelNameController.text}',
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
                        const Divider(
                          height: 20,
                          color: lightBlackColor,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  MdiIcons.accountOutline,
                                  size: 13,
                                  color: blueColor,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  noOfOwnersSelectedValue.toString(),
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: lightBlackColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  MdiIcons.fuel,
                                  size: 13,
                                  color: blueColor,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  fuelTypeSelectedValue.toString(),
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: lightBlackColor,
                                  ),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  MdiIcons.calendarOutline,
                                  size: 13,
                                  color: blueColor,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  yorSelectedValue.toString(),
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: lightBlackColor,
                                  ),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  MdiIcons.mapMarkerDistance,
                                  size: 13,
                                  color: blueColor,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  '${kmFormat.format(
                                    int.parse(kmDrivenController.text),
                                  )} Kms',
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: lightBlackColor,
                                  ),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
                          text: 'Update',
                          icon: MdiIcons.checkOutline,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Get.back();
                            var uid = widget.productData.id;
                            setSearchParams({
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

                            provider.updatedDataToFirestore.addAll({
                              'title':
                                  '$yorSelectedValue ${brandNameController.text} ${modelNameController.text}',
                              'brandName': brandNameController.text,
                              'modelName': modelNameController.text,
                              'fuelType': fuelTypeSelectedValue,
                              'yearOfReg': int.parse(yorSelectedValue!),
                              'color': colorSelectedValue,
                              'kmsDriven': int.parse(kmDrivenController.text),
                              'noOfOwners': noOfOwnersSelectedValue,
                              'description': descriptionController.text,
                              'price': int.parse(priceController.text),
                              'searchQueries': setSearchParams(
                                s: '${brandNameController.text.toLowerCase()} ${modelNameController.text.toLowerCase()}',
                                n: brandNameController.text.length +
                                    modelNameController.text.length +
                                    1,
                                catName: 'vehicles',
                                subCatName:
                                    widget.productData['subCat'].toLowerCase(),
                              ),
                              'isActive': false,
                              'isRejected': false,
                              'isShowedInConsole': true,
                            });
                            await updateProductOnFirebase(provider, uid);
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
                            Get.back();
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
          leading: IconButton(
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(MdiIcons.closeCircleOutline),
          ),
          centerTitle: true,
          title: Text(
            'Edit your product listing',
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
                    'Step 1 - Vehicle Details',
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
                  child: TextFieldLabel(labelText: 'Brand'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: brandNameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    hint: 'Ex: Maruti Suzuki, Honda',
                    maxLength: 20,
                    isEnabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter brand name';
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
                  child: TextFieldLabel(labelText: 'Model/Variant'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: modelNameController,
                    keyboardType: TextInputType.text,
                    hint: 'Ex: Swift ZDI+, Activa 6G',
                    maxLength: 40,
                    textInputAction: TextInputAction.next,
                    isEnabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter model/variant name';
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
                  child: TextFieldLabel(labelText: 'Kms Driven'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: kmDrivenController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    maxLength: 7,
                    enabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter kilometres driven';
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
                      hintText: 'Ex: 20000, 150000',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      fillColor: greyColor,
                      filled: true,
                      counterText: '',
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
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: blueColor,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
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
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Fuel type'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: greyColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(5),
                        itemHeight: 50,
                        hint: Text(
                          '--Select--',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.normal,
                          color: fadedColor,
                        ),
                        icon: const Icon(
                          MdiIcons.chevronDown,
                          size: 15,
                        ),
                        items: fuelType
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: fuelTypeSelectedValue,
                        onChanged: (value) {
                          setState(() {
                            fuelTypeSelectedValue = value as String;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Year of Registration'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: greyColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(5),
                        itemHeight: 50,
                        hint: Text(
                          '--Select--',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.normal,
                          color: fadedColor,
                        ),
                        icon: const Icon(
                          MdiIcons.chevronDown,
                          size: 15,
                        ),
                        items: yor
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: yorSelectedValue,
                        onChanged: (value) {
                          setState(() {
                            yorSelectedValue = value as String;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Color'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: greyColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(5),
                        itemHeight: 50,
                        hint: Text(
                          '--Select--',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.normal,
                          color: fadedColor,
                        ),
                        icon: const Icon(
                          MdiIcons.chevronDown,
                          size: 15,
                        ),
                        items: colors
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: colorSelectedValue,
                        onChanged: (value) {
                          setState(() {
                            colorSelectedValue = value as String;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Number of Owners'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: greyColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(5),
                        itemHeight: 50,
                        hint: Text(
                          '--Select--',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.normal,
                          color: fadedColor,
                        ),
                        icon: const Icon(
                          MdiIcons.chevronDown,
                          size: 15,
                        ),
                        items: noOfOwners
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: noOfOwnersSelectedValue,
                        onChanged: (value) {
                          setState(() {
                            noOfOwnersSelectedValue = value as String;
                          });
                        },
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
                    'Step 2 - Listing Details',
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
                  child: TextFieldLabel(labelText: 'Description'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    hint:
                        'Briefly describe your vehicle to increase your chances of getting a good deal. Include details like condition, features, reason for selling, etc.',
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
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
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
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: blueColor,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
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
                  onPressed: validateForm,
                  icon: MdiIcons.arrowRight,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: whiteColor,
                ),
        ),
      ),
    );
  }
}
