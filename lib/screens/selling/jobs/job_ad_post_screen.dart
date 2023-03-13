import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/loading_button.dart';
import '../../../widgets/text_field_label.dart';
import '../utils/selling_utils.dart';
import '/screens/main_screen.dart';
import '/screens/selling/congratulations_screen.dart';
import '/widgets/custom_button_without_icon.dart';
import '/provider/seller_form_provider.dart';
import '/utils/utils.dart';
import '/widgets/custom_text_field.dart';
import '/services/firebase_services.dart';
import '/widgets/custom_button.dart';
import '/widgets/image_picker_widget.dart';

class JobAdPostScreen extends StatefulWidget {
  final String subCatName;
  const JobAdPostScreen({
    super.key,
    required this.subCatName,
  });

  @override
  State<JobAdPostScreen> createState() => _JobAdPostScreenState();
}

class _JobAdPostScreenState extends State<JobAdPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController subCatNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salaryFromController = TextEditingController();
  final TextEditingController salaryToController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FirebaseServices _services = FirebaseServices();
  double latitude = 0;
  double longitude = 0;
  String area = '';
  String city = '';
  String state = '';
  String country = '';

  late StreamSubscription subscription;
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
    getConnectivity();
    subCatNameController.text = 'Jobs > ${widget.subCatName}';
    getUserLocation();
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
    subCatNameController.dispose();
    salaryFromController.dispose();
    salaryToController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  dynamic salaryPeriodSelectedValue;
  dynamic positionTypeSelectedValue;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<SellerFormProvider>(context);

    publishProductToFirebase(SellerFormProvider provider) async {
      try {
        await _services.listings
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
        return;
      }
      if (salaryPeriodSelectedValue == null ||
          positionTypeSelectedValue == null ||
          descriptionController.text.isEmpty ||
          salaryFromController.text.isEmpty ||
          salaryToController.text.isEmpty ||
          titleController.text.isEmpty) {
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
                      'Ready to post this job?',
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                                              fontWeight: FontWeight.w700,
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
                                      'From: ${priceFormat.format(
                                        int.parse(salaryFromController.text),
                                      )}',
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w700,
                                        color: blueColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'To: ${priceFormat.format(
                                        int.parse(salaryToController.text),
                                      )}',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  MdiIcons.clock,
                                  size: 13,
                                  color: blueColor,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  salaryPeriodSelectedValue.toString(),
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
                                  MdiIcons.calendar,
                                  size: 13,
                                  color: blueColor,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  positionTypeSelectedValue.toString(),
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
                          text: 'Post',
                          icon: MdiIcons.check,
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
                            setSearchParams({
                              // required String s,
                              // required int n,
                              required String catName,
                              required String subCatName,
                            }) {
                              List<String> searchQueries = [];
                              // for (int i = 0; i < n; i++) {
                              //   String temp = '';
                              //   for (int j = i; j < n; j++) {
                              //     temp += s[j];
                              //     if (temp.length >= 3) {
                              //       searchQueries.add(temp);
                              //     }
                              //   }
                              // }
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
                              'catName': 'Jobs',
                              'subCat': widget.subCatName,
                              'salaryPeriod': salaryPeriodSelectedValue,
                              'positionType': positionTypeSelectedValue,
                              'title': titleController.text,
                              'description': descriptionController.text,
                              'salaryFrom':
                                  int.parse(salaryFromController.text),
                              'salaryTo': int.parse(salaryToController.text),
                              'sellerUid': _services.user!.uid,
                              'images': urls,
                              'postedAt': time,
                              'favorites': [],
                              'views': [],
                              'searchQueries': setSearchParams(
                                // s: titleController.text.toLowerCase(),
                                // n: titleController.text.length + 1,
                                catName: 'Jobs',
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
                              salaryPeriodSelectedValue = null;
                              positionTypeSelectedValue = null;
                              titleController.text = '';
                              descriptionController.text = '';
                              salaryFromController.text = '';
                              salaryToController.text = '';
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
                              salaryPeriodSelectedValue = null;
                              positionTypeSelectedValue = null;
                              titleController.text = '';
                              descriptionController.text = '';
                              salaryFromController.text = '';
                              salaryToController.text = '';
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
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(MdiIcons.closeCircleOutline),
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
            'Create your job listing',
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
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blackColor,
                  child: Text(
                    'Step 1 - User Details',
                    textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blackColor,
                  child: Text(
                    'Step 2 - Job Details',
                    textAlign: TextAlign.center,
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
                  child: TextFieldLabel(labelText: 'Salary from'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: salaryFromController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    enabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter salary from';
                      }
                      if (int.parse(salaryFromController.text) >
                          int.parse(salaryToController.text)) {
                        return 'Salary from should be less than Salary to';
                      }
                      return null;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: '1,45,000',
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
                  child: TextFieldLabel(labelText: 'Salary to'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: salaryToController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    enabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter salary to';
                      }
                      if (int.parse(salaryToController.text) <
                          int.parse(salaryFromController.text)) {
                        return 'Salary to should be more than Salary from';
                      }
                      return null;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: '2,00,000',
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
                  child: TextFieldLabel(labelText: 'Salary Period'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: GFDropdown(
                      isExpanded: true,
                      padding: const EdgeInsets.all(15),
                      borderRadius: BorderRadius.circular(5),
                      itemHeight: 50,
                      dropdownButtonColor: greyColor,
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
                      items: salaryPeriod
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
                      value: salaryPeriodSelectedValue,
                      onChanged: (value) {
                        setState(() {
                          salaryPeriodSelectedValue = value as String;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFieldLabel(labelText: 'Position Type'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: GFDropdown(
                      isExpanded: true,
                      padding: const EdgeInsets.all(15),
                      borderRadius: BorderRadius.circular(5),
                      itemHeight: 50,
                      dropdownButtonColor: greyColor,
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
                      items: positionType
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
                      value: positionTypeSelectedValue,
                      onChanged: (value) {
                        setState(() {
                          positionTypeSelectedValue = value as String;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blackColor,
                  child: Text(
                    'Step 3 - Listing Details',
                    textAlign: TextAlign.center,
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
                  child: TextFieldLabel(labelText: 'Title'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: titleController,
                    keyboardType: TextInputType.multiline,
                    hint: 'Mention key features of this job',
                    maxLength: 35,
                    showCounterText: true,
                    isEnabled: isLoading ? false : true,
                    textInputAction: TextInputAction.newline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
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
                  child: TextFieldLabel(labelText: 'Description'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    hint:
                        'Briefly describe this job to increase your chances of finding candidates',
                    maxLength: 300,
                    maxLines: 4,
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
                  height: 20,
                ),
                Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: blackColor,
                  child: Text(
                    'Step 4 - Job Images',
                    textAlign: TextAlign.center,
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
