import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/selling/congratulations_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../provider/seller_form_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/firebase_services.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_widget.dart';

class VehicleAdPostScreen extends StatefulWidget {
  final String subCatName;
  const VehicleAdPostScreen({
    super.key,
    required this.subCatName,
  });

  @override
  State<VehicleAdPostScreen> createState() => _VehicleAdPostScreenState();
}

class _VehicleAdPostScreenState extends State<VehicleAdPostScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController brandNameController = TextEditingController();
  TextEditingController modelNameController = TextEditingController();
  TextEditingController kmDrivenController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController fuelTypeSearchController = TextEditingController();
  TextEditingController yorSearchController = TextEditingController();
  TextEditingController noOfOwnersSearchController = TextEditingController();

  final FirebaseServices _services = FirebaseServices();

  // @override
  // void initState() {
  //   _services.getUserData().then((value) {
  //     setState(() {
  //       if (value['mobile'] == null) {
  //         sellerMobileNumber = '';
  //       } else if (value['mobile'] != null) {
  //         sellerMobileNumber = value['mobile'];
  //       }
  //       if (value['email'] == null) {
  //         sellerEmailAddress = '';
  //       } else if (value['email'] != null) {
  //         sellerEmailAddress = value['email'];
  //       }
  //     });
  //   });
  //   super.initState();
  // }

  @override
  void dispose() {
    titleController.dispose();
    brandNameController.dispose();
    modelNameController.dispose();
    kmDrivenController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    fuelTypeSearchController.dispose();
    yorSearchController.dispose();
    noOfOwnersSearchController.dispose();
    super.dispose();
  }

  final List<String> fuelType = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'CNG',
    'LPG',
    'Hydrogen',
  ];
  final List<String> yor = [
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
    '2014',
    '2013',
    '2012',
    '2011',
    '2010',
    '2009',
    '2008',
    '2007',
    '2006',
    '2005',
    '2004',
    '2003',
    '2002',
    '2001',
    '2000',
    '1999',
    '1998',
    '1997',
    '1996',
    '1995',
    '1994',
    '1993',
    '1992',
    '1991',
    '1990',
    'Older than 1990',
  ];
  final List<String> noOfOwners = ['1st', '2nd', '3rd', '4th', '5th +'];

  String? fuelTypeSelectedValue;
  String? yorSelectedValue;
  String? noOfOwnersSelectedValue;
  var uuid = const Uuid();
  var priceFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '₹',
    name: '',
  );
  var kmFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '',
    name: '',
  );
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerFormProvider>(context);

    TextEditingController subCatNameController =
        TextEditingController(text: 'Vehicles > ${widget.subCatName}');

    publishProductToFirebase(SellerFormProvider provider) async {
      return await _services.listings
          .doc(uuid.v1())
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
          content: 'Some error occurred. Please try again.',
        );
        setState(() {
          isLoading = false;
        });
      });
    }

    validateForm() async {
      if (_formKey.currentState!.validate()) {
        if (brandNameController.text.isNotEmpty &&
            modelNameController.text.isNotEmpty &&
            fuelTypeSelectedValue != null &&
            yorSelectedValue != null &&
            noOfOwnersSelectedValue != null &&
            descriptionController.text.isNotEmpty &&
            priceController.text.isNotEmpty &&
            kmDrivenController.text.isNotEmpty &&
            provider.imagePaths.isNotEmpty) {
          showDialog(
            context: context,
            barrierColor: Colors.black87,
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
                      borderRadius: BorderRadius.circular(10),
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    provider.imagePaths[0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '+${(provider.imagesCount - 1).toString()} more',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: fadedColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${brandNameController.text} ${modelNameController.text}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  maxLines: 3,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  priceFormat.format(
                                    int.parse(priceController.text),
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: blueColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        color: fadedColor,
                        thickness: 1,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.solidUser,
                                size: 13,
                                color: blueColor,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                noOfOwnersSelectedValue.toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black54,
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
                                FontAwesomeIcons.gasPump,
                                size: 13,
                                color: blueColor,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                fuelTypeSelectedValue.toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black54,
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
                                FontAwesomeIcons.calendarCheck,
                                size: 13,
                                color: blueColor,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                yorSelectedValue.toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black54,
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
                                FontAwesomeIcons.road,
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
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const Divider(
                            height: 20,
                            color: fadedColor,
                            thickness: 1,
                          ),
                          Text(
                            'Description - ${descriptionController.text}',
                            style: GoogleFonts.poppins(
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
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                  CustomButton(
                    text: 'Confirm & Post',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Navigator.pop(context);
                      List<String> urls =
                          await provider.uploadFiles(provider.imagePaths);
                      provider.dataToFirestore.addAll({
                        'catName': 'Vehicles',
                        'subCat': widget.subCatName,
                        'title':
                            '${brandNameController.text} ${modelNameController.text}',
                        'brandName': brandNameController.text,
                        'modelName': modelNameController.text,
                        'fuelType': fuelTypeSelectedValue,
                        'yearOfReg': int.parse(yorSelectedValue!),
                        'kmsDriven': int.parse(kmDrivenController.text),
                        'noOfOwners': noOfOwnersSelectedValue,
                        'description': descriptionController.text,
                        'price': int.parse(priceController.text),
                        'sellerUid': _services.user!.uid,
                        'images': urls,
                        'postedAt': DateTime.now().millisecondsSinceEpoch,
                      });
                      publishProductToFirebase(provider);
                    },
                    icon: FontAwesomeIcons.check,
                    bgColor: blueColor,
                    textIconColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Go Back & Check',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: FontAwesomeIcons.reply,
                    bgColor: blackColor,
                    textIconColor: Colors.white,
                  ),
                ],
              );
            },
          );
        }
        if (provider.imagePaths.isEmpty) {
          showSnackBar(
            context: context,
            content: 'Please upload some images of the product',
          );
        } else {
          showSnackBar(
            context: context,
            content: 'Please fill all the fields marked with *',
          );
        }
      } else {
        showSnackBar(
          context: context,
          content: 'Please fill all the fields marked with *',
        );
      }
    }

    resetAll() {
      showDialog(
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
                  borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
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
              CustomButton(
                text: 'Yes, Reset all',
                onPressed: () {
                  setState(() {
                    brandNameController.text = '';
                    modelNameController.text = '';
                    fuelTypeSelectedValue = null;
                    yorSelectedValue = null;
                    kmDrivenController.text = '';
                    noOfOwnersSelectedValue = null;
                    descriptionController.text = '';
                    priceController.text = '';
                    provider.imagePaths.clear();
                    provider.clearImagesCount();
                  });
                  Navigator.pop(context);
                },
                icon: FontAwesomeIcons.solidTrashCan,
                bgColor: Colors.red,
                textIconColor: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                text: 'No, Cancel',
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: FontAwesomeIcons.xmark,
                bgColor: blackColor,
                textIconColor: Colors.white,
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isLoading ? null : resetAll,
            child: Text(
              'Reset All',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: blueColor,
              ),
            ),
          ),
        ],
        title: Text(
          'Create your listing',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        child: SingleChildScrollView(
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
                    'Step 1 - Vehicle Details',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
                    controller: brandNameController,
                    keyboardType: TextInputType.text,
                    label: 'Brand Name*',
                    hint: 'Enter the brand name. Ex: Maruti Suzuki, Honda',
                    maxLength: 30,
                    textInputAction: TextInputAction.next,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: modelNameController,
                    keyboardType: TextInputType.text,
                    label: 'Model*',
                    hint: 'Enter the model name. Ex: Swift, Activa',
                    maxLength: 40,
                    textInputAction: TextInputAction.next,
                    isEnabled: isLoading ? false : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter model name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Text(
                        'Fuel type*',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 111, 111, 111),
                      ),
                      buttonDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 235, 239, 243),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: const Icon(
                        FontAwesomeIcons.chevronDown,
                        size: 20,
                      ),
                      iconOnClick: const Icon(
                        FontAwesomeIcons.chevronUp,
                        size: 20,
                      ),
                      buttonPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      items: fuelType
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(
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
                      buttonHeight: 50,
                      buttonWidth: MediaQuery.of(context).size.width,
                      itemHeight: 50,
                      dropdownMaxHeight: MediaQuery.of(context).size.width,
                      searchController: fuelTypeSearchController,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          controller: fuelTypeSearchController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for an item...',
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return (item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue));
                      },
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          fuelTypeSearchController.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Text(
                        'Year of Registration*',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 111, 111, 111),
                      ),
                      buttonDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 235, 239, 243),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: const Icon(
                        FontAwesomeIcons.chevronDown,
                        size: 20,
                      ),
                      iconOnClick: const Icon(
                        FontAwesomeIcons.chevronUp,
                        size: 20,
                      ),
                      buttonPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      items: yor
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(
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
                      buttonHeight: 50,
                      buttonWidth: MediaQuery.of(context).size.width,
                      itemHeight: 50,
                      dropdownMaxHeight: MediaQuery.of(context).size.width,
                      searchController: yorSearchController,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          controller: yorSearchController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for an item...',
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return (item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue));
                      },
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          yorSearchController.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Kms Driven*',
                      hintText: 'Enter the Kms driven. Ex: 20000, 150000',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      fillColor: greyColor,
                      filled: true,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 0,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 0,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: blueColor,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromARGB(255, 111, 111, 111),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                      floatingLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Text(
                        'Number of Owners*',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 111, 111, 111),
                      ),
                      buttonDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 235, 239, 243),
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      icon: const Icon(
                        FontAwesomeIcons.chevronDown,
                        size: 20,
                      ),
                      iconOnClick: const Icon(
                        FontAwesomeIcons.chevronUp,
                        size: 20,
                      ),
                      buttonPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      items: noOfOwners
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(
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
                      buttonHeight: 50,
                      buttonWidth: MediaQuery.of(context).size.width,
                      itemHeight: 50,
                      dropdownMaxHeight: MediaQuery.of(context).size.width,
                      searchController: noOfOwnersSearchController,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          controller: noOfOwnersSearchController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for an item...',
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return (item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue));
                      },
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          noOfOwnersSearchController.clear();
                        }
                      },
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
                    'Step 2 - Listing Details',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.text,
                    label: 'Description*',
                    hint:
                        'Briefly describe your vehicle to increase your chances of getting a good deal. Include details like condition, features, reason for selling, etc.',
                    maxLength: 1000,
                    maxLines: 3,
                    showCounterText: true,
                    isEnabled: isLoading ? false : true,
                    textInputAction: TextInputAction.next,
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
                        return 'Please enter the price for your listing';
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 0,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: blueColor,
                          width: 1.5,
                          strokeAlign: StrokeAlign.inside,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromARGB(255, 111, 111, 111),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                      floatingLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.black87,
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
                    'Step 3 - Upload Product Images',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 244, 241, 241),
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
                bgColor: blackColor,
                textIconColor: Colors.white,
              )
            : CustomButton(
                text: 'Proceed',
                onPressed: () {
                  validateForm();
                },
                icon: FontAwesomeIcons.arrowRight,
                bgColor: blackColor,
                textIconColor: Colors.white,
              ),
      ),
    );
  }
}
