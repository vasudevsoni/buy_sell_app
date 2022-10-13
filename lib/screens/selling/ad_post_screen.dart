import 'package:buy_sell_app/screens/selling/congratulations_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../provider/seller_form_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button_without_icon.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/firebase_services.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_widget.dart';
import '../main_screen.dart';

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

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  final FirebaseServices _services = FirebaseServices();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  var uuid = const Uuid();
  var priceFormat = NumberFormat.currency(
    locale: 'HI',
    decimalDigits: 0,
    symbol: '₹',
    name: '',
  );
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerFormProvider>(context);

    TextEditingController subCatNameController =
        TextEditingController(text: '${widget.catName} > ${widget.subCatName}');

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
        if (titleController.text.isNotEmpty &&
            descriptionController.text.isNotEmpty &&
            priceController.text.isNotEmpty &&
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        FontAwesomeIcons.triangleExclamation,
                                        size: 20,
                                        color: redColor,
                                      );
                                    },
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
                                  titleController.text,
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
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                  CustomButtonWithoutIcon(
                    text: 'Confirm & Post',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      Navigator.pop(context);
                      List<String> urls =
                          await provider.uploadFiles(provider.imagePaths);
                      provider.dataToFirestore.addAll({
                        'catName': widget.catName,
                        'subCat': widget.subCatName,
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'price': int.parse(priceController.text),
                        'sellerUid': _services.user!.uid,
                        'images': urls,
                        'postedAt': DateTime.now().millisecondsSinceEpoch,
                      });
                      publishProductToFirebase(provider);
                    },
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtonWithoutIcon(
                    text: 'Go Back & Check',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    bgColor: Colors.white,
                    borderColor: blueColor,
                    textIconColor: blueColor,
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
                  Navigator.pop(context);
                },
                bgColor: redColor,
                borderColor: redColor,
                textIconColor: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButtonWithoutIcon(
                text: 'No, Cancel',
                onPressed: () {
                  Navigator.pop(context);
                },
                bgColor: Colors.white,
                borderColor: blackColor,
                textIconColor: blackColor,
              ),
            ],
          );
        },
      );
    }

    closePageAndGoToHome() {
      showDialog(
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
                  borderRadius: BorderRadius.circular(10),
                ),
                color: greyColor,
              ),
              child: Text(
                'Are you sure you want to cancel your listing creation? All details will be lost.',
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
              CustomButtonWithoutIcon(
                text: 'Yes, Cancel',
                onPressed: () {
                  setState(() {
                    descriptionController.text = '';
                    priceController.text = '';
                    provider.imagePaths.clear();
                    provider.clearImagesCount();
                  });
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MainScreen.routeName,
                    (route) => false,
                  );
                  showSnackBar(
                    context: context,
                    content: 'Listing creation cancelled',
                  );
                },
                bgColor: redColor,
                borderColor: redColor,
                textIconColor: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButtonWithoutIcon(
                text: 'No, Continue',
                onPressed: () {
                  Navigator.pop(context);
                },
                bgColor: Colors.white,
                borderColor: blackColor,
                textIconColor: blackColor,
              ),
            ],
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.2,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          leading: IconButton(
            onPressed: closePageAndGoToHome,
            enableFeedback: true,
            icon: const Icon(FontAwesomeIcons.xmark),
          ),
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
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      label: 'Title*',
                      hint: 'Enter the title',
                      maxLength: 30,
                      textInputAction: TextInputAction.next,
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
                      maxLength: 1000,
                      maxLines: 3,
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
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: blueColor,
                            width: 1.5,
                            strokeAlign: StrokeAlign.inside,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                      'Step 2 - Upload Product Images',
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
                  borderColor: blackColor,
                  textIconColor: Colors.white,
                )
              : CustomButton(
                  text: 'Proceed',
                  onPressed: () {
                    validateForm();
                  },
                  icon: FontAwesomeIcons.arrowRight,
                  bgColor: blueColor,
                  borderColor: blueColor,
                  textIconColor: Colors.white,
                ),
        ),
      ),
    );
  }
}
