import 'package:buy_sell_app/widgets/custom_button_without_icon.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:location/location.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../widgets/loading_button.dart';
import '../../widgets/svg_picture.dart';
import '/provider/location_provider.dart';
import '/screens/selling/seller_categories_list_screen.dart';
import '/services/firebase_services.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import '/screens/main_screen.dart';

class LocationScreen extends StatefulWidget {
  final bool isOpenedFromSellButton;
  const LocationScreen({Key? key, required this.isOpenedFromSellButton})
      : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final FirebaseServices _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;
  final Location location = Location();
  late bool serviceEnabled;
  late PermissionStatus permissionGranted;
  bool isLoading = false;

  Future<bool> getAddress() async {
    final locationProv = Provider.of<LocationProvider>(context, listen: false);
    try {
      List placemarks = await geocode.placemarkFromCoordinates(
        locationProv.locationData!.latitude as double,
        locationProv.locationData!.longitude as double,
        localeIdentifier: 'en_IN',
      );
      await _services.updateUserDetails(user!.uid, {
        'location': {
          'latitude': locationProv.locationData!.latitude,
          'longitude': locationProv.locationData!.longitude,
          'street': placemarks[0].street.toString(),
          'area': placemarks[0].subLocality == ''
              ? placemarks[0].locality.toString()
              : placemarks[0].subLocality.toString(),
          'city': placemarks[0].locality.toString(),
          'state': placemarks[0].administrativeArea.toString(),
          'country': placemarks[0].country.toString(),
          'pin': placemarks[0].postalCode.toString(),
        },
      });
      if (mounted) {
        showSnackBar(
          content: placemarks[0].subLocality == ''
              ? 'Location set to ${placemarks[0].locality.toString()}'
              : 'Location set to ${placemarks[0].subLocality.toString()}',
          color: blueColor,
        );
      }
      return true;
    } catch (e) {
      showSnackBar(
        content: 'Unable to get your current location. Please try again',
        color: redColor,
      );
      return false;
    }
  }

  Future<bool> getUserLocation() async {
    final locationProv = Provider.of<LocationProvider>(context, listen: false);
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          showSnackBar(
            content:
                'Location services are disabled. Please enable services to continue',
            color: redColor,
          );
          return false;
        }
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          showSnackBar(
            content:
                'Location access was denied. Please allow access for a better experience',
            color: redColor,
          );
          return false;
        }
      }
      if (permissionGranted == PermissionStatus.deniedForever) {
        showSnackBar(
          content:
              'Location services are permanently disabled, unable to fetch location',
          color: redColor,
        );
        return false;
      }
      final value = await location.getLocation();
      locationProv.updateLocation(value);
      return await getAddress();
    } catch (e) {
      showSnackBar(
        content: 'Unable to get your current location. Please try again',
        color: redColor,
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Set your location',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Set your location to get nearby product recommendations and to sell your own products',
                style: GoogleFonts.interTight(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'To enjoy all that we have to offer, we need to know where to look for them',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w500,
                  color: lightBlackColor,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(15),
              height: size.height * 0.2,
              width: size.height * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: greyColor,
              ),
              child: const SVGPictureWidget(
                url:
                    'https://res.cloudinary.com/bechdeapp/image/upload/v1674459472/illustrations/Location_meoabg.svg',
                fit: BoxFit.contain,
                semanticsLabel: 'Location image',
              ),
            ),
            const Spacer(),
            isLoading
                ? Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: const LoadingButton(
                      bgColor: blueColor,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: CustomButton(
                      text: 'Use Current Location',
                      icon: MdiIcons.crosshairsGps,
                      bgColor: blueColor,
                      borderColor: blueColor,
                      textIconColor: whiteColor,
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await getUserLocation().then((value) {
                          if (!value) {
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (!widget.isOpenedFromSellButton) {
                            Get.offAll(
                              () => const MainScreen(selectedIndex: 0),
                            );
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          Get.back();
                          Get.to(
                            () => const SellerCategoriesListScreen(),
                          );
                        });
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ),
            Container(
              margin: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 15,
              ),
              child: CustomButtonWithoutIcon(
                text: 'Skip',
                bgColor: whiteColor,
                borderColor: blackColor,
                textIconColor: blackColor,
                isDisabled: isLoading,
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
