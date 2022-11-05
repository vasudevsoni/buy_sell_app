import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/seller_form_provider.dart';
import '../../../services/firebase_services.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_button_without_icon.dart';
import '../../../widgets/custom_text_field.dart';

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

  TextEditingController subCatNameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController brandNameController = TextEditingController();
  TextEditingController modelNameController = TextEditingController();
  TextEditingController kmDrivenController = TextEditingController();
  TextEditingController fuelTypeSearchController = TextEditingController();
  TextEditingController yorSearchController = TextEditingController();
  TextEditingController colorsSearchController = TextEditingController();
  TextEditingController noOfOwnersSearchController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String? fuelTypeSelectedValue;
  String? yorSelectedValue;
  String? noOfOwnersSelectedValue;
  String? colorSelectedValue;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    subCatNameController.dispose();
    brandNameController.dispose();
    modelNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    kmDrivenController.dispose();
    fuelTypeSearchController.dispose();
    yorSearchController.dispose();
    noOfOwnersSearchController.dispose();
    colorsSearchController.dispose();
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
    '1989',
    '1988',
    '1987',
    '1986',
    '1985',
    '1984',
    '1983',
    '1982',
    '1981',
    '1980',
    '1979',
    '1978',
    '1977',
    '1976',
    '1975',
    '1974',
    '1973',
    '1972',
    '1971',
    '1970',
    '1969',
    '1968',
    '1967',
    '1966',
    '1965',
    '1964',
    '1963',
    '1962',
    '1961',
    '1960',
    '1959',
    '1958',
    '1957',
    '1956',
    '1955',
    '1954',
    '1953',
    '1952',
    '1951',
    '1950',
    '1949',
    '1948',
    '1947',
    '1946',
    '1945',
    '1944',
    '1943',
    '1942',
    '1941',
    '1940',
    '1939',
    '1938',
    '1937',
    '1936',
    '1935',
    '1934',
    '1933',
    '1932',
    '1931',
    '1930',
    '1929',
    '1928',
    '1927',
    '1926',
    '1925',
    '1924',
    '1923',
    '1922',
    '1921',
    '1920',
    '1919',
    '1918',
    '1917',
    '1916',
    '1915',
    '1914',
    '1913',
    '1912',
    '1911',
    '1910',
    '1909',
    '1908',
    '1907',
    '1906',
    '1905',
    '1904',
    '1903',
    '1902',
    '1901',
    '1900',
  ];
  final List<String> noOfOwners = ['1st', '2nd', '3rd', '4th', '5th +'];
  final List<String> colors = [
    'White',
    'Silver',
    'Grey',
    'Black',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Purple',
    'Brown',
    'Orange',
    'Gold',
    'Others',
  ];

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
          context: context,
          content: 'Details updated. Listing will be active once reviewed.',
          color: blueColor,
        );
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
        if (brandNameController.text.isNotEmpty &&
            modelNameController.text.isNotEmpty &&
            fuelTypeSelectedValue != null &&
            yorSelectedValue != null &&
            noOfOwnersSelectedValue != null &&
            descriptionController.text.isNotEmpty &&
            priceController.text.isNotEmpty &&
            kmDrivenController.text.isNotEmpty &&
            colorSelectedValue != null) {
          showModal(
            configuration: const FadeScaleTransitionConfiguration(),
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Ready to update?',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$yorSelectedValue ${brandNameController.text} ${modelNameController.text}',
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
                                FontAwesomeIcons.user,
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
                                FontAwesomeIcons.calendar,
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
                    text: 'Confirm & Update',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Get.back();
                      var uid = widget.productData['postedAt'];
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
                        'isActive': false,
                      });
                      await updateProductOnFirebase(provider, uid.toString());
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
        } else {
          showSnackBar(
            context: context,
            content: 'Please fill all the required fields.',
            color: redColor,
          );
        }
      } else {
        showSnackBar(
          context: context,
          content: 'Please fill all the required fields.',
          color: redColor,
        );
      }
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
                  Get.back();
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
          leading: IconButton(
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(FontAwesomeIcons.circleXmark),
          ),
          centerTitle: true,
          title: Text(
            'Edit your listing',
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
                      'Step 1 - Vehicle Details',
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
                      controller: brandNameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      label: 'Brand Name*',
                      hint: 'Enter the brand name. Ex: Maruti Suzuki, Honda',
                      maxLength: 30,
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
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
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
                          color: greyColor,
                        ),
                        buttonDecoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.chevronDown,
                          size: 15,
                        ),
                        iconOnClick: const Icon(
                          FontAwesomeIcons.chevronUp,
                          size: 15,
                        ),
                        buttonPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
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
                              hintText: 'Search for fuel type',
                              hintStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
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
                          color: greyColor,
                        ),
                        buttonDecoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.chevronDown,
                          size: 15,
                        ),
                        iconOnClick: const Icon(
                          FontAwesomeIcons.chevronUp,
                          size: 15,
                        ),
                        buttonPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
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
                              hintText: 'Search for an year',
                              hintStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        isExpanded: true,
                        hint: Text(
                          'Color*',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: greyColor,
                        ),
                        buttonDecoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.chevronDown,
                          size: 15,
                        ),
                        iconOnClick: const Icon(
                          FontAwesomeIcons.chevronUp,
                          size: 15,
                        ),
                        buttonPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        items: colors
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
                        value: colorSelectedValue,
                        onChanged: (value) {
                          setState(() {
                            colorSelectedValue = value as String;
                          });
                        },
                        buttonHeight: 50,
                        buttonWidth: MediaQuery.of(context).size.width,
                        itemHeight: 50,
                        dropdownMaxHeight: MediaQuery.of(context).size.width,
                        searchController: colorsSearchController,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            controller: colorsSearchController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Search for a color',
                              hintStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
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
                            colorsSearchController.clear();
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
                          'Number of Owners*',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: greyColor,
                        ),
                        buttonDecoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        icon: const Icon(
                          FontAwesomeIcons.chevronDown,
                          size: 15,
                        ),
                        iconOnClick: const Icon(
                          FontAwesomeIcons.chevronUp,
                          size: 15,
                        ),
                        buttonPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
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
                                borderRadius: BorderRadius.circular(5),
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
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      label: 'Description*',
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
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
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
