import 'package:buy_sell_app/screens/selling/seller_categories_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../../provider/location_provider.dart';
import '../../services/firebase_services.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../../screens/main_screen.dart';

class LocationScreen extends StatefulWidget {
  final bool isOpenedFromSellButton;
  const LocationScreen({Key? key, required this.isOpenedFromSellButton})
      : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool isLoading = false;
  final FirebaseServices _services = FirebaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  late bool serviceEnabled;
  Location location = Location();
  late PermissionStatus permissionGranted;

  Future<void> getAddress() async {
    final locationProv = Provider.of<LocationProvider>(context, listen: false);
    try {
      List<geocode.Placemark> placemarks =
          await geocode.placemarkFromCoordinates(
        locationProv.locationData!.latitude as double,
        locationProv.locationData!.longitude as double,
        localeIdentifier: 'en_IN',
      );
      await _services.updateUserDetails(user!.uid, {
        'location': {
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
          context: context,
          content: placemarks[0].subLocality == ''
              ? 'Location set to ${placemarks[0].locality.toString()}'
              : 'Location set to ${placemarks[0].subLocality.toString()}',
          color: blueColor,
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        content: 'Unable to get your current location. Please try again.',
        color: redColor,
      );
    }
  }

  Future<LocationData?> getUserLocation() async {
    final locationProv = Provider.of<LocationProvider>(context, listen: false);

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        showSnackBar(
          context: context,
          content:
              'Location services are disabled. Please enable services to continue.',
          color: redColor,
        );
        return null;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        showSnackBar(
          context: context,
          content:
              'Location access was denied. Please allow access for a better experience.',
          color: redColor,
        );
        return null;
      }
    } else if (permissionGranted == PermissionStatus.deniedForever) {
      showSnackBar(
        context: context,
        content:
            'Location services are permanently disabled, unable to fetch location.',
        color: redColor,
      );
    }
    await location.getLocation().then((value) {
      locationProv.updateLocation(value);
      getAddress();
    });
    return locationProv.locationData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Set your location',
          style: GoogleFonts.poppins(
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Set your location to get nearby product recommendations and to sell your own products',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  'To enjoy all that we have to offer you we need to know where to look for them',
                  style: GoogleFonts.poppins(
                    color: lightBlackColor,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://media.istockphoto.com/vectors/vector-map-with-pin-pointer-illustration-vector-id535913739?k=20&m=535913739&s=612x612&w=0&h=cS_zINbhJ9T9vRlaAc4S_-Yd45f6qs5zliFHZ7KNhFI=',
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  isLoading
                      ? Container(
                          margin: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                          ),
                          child: CustomButton(
                            text: 'Fetching location',
                            icon: FontAwesomeIcons.spinner,
                            bgColor: greyColor,
                            borderColor: greyColor,
                            textIconColor: blackColor,
                            isDisabled: true,
                            onPressed: () {},
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                          ),
                          child: CustomButton(
                            text: 'set location using gps',
                            icon: FontAwesomeIcons.locationCrosshairs,
                            bgColor: blueColor,
                            borderColor: blueColor,
                            textIconColor: whiteColor,
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await getUserLocation().then((value) {
                                if (value != null) {
                                  if (widget.isOpenedFromSellButton) {
                                    Get.back();
                                    Get.reloadAll();
                                    Get.toNamed(
                                        SellerCategoriesListScreen.routeName);
                                  } else {
                                    Get.offAll(() => const MainScreen(
                                          selectedIndex: 0,
                                        ));
                                  }
                                } else {
                                  return;
                                }
                              });
                              setState(() {
                                isLoading = false;
                              });
                            },
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 15,
                    ),
                    child: CustomButton(
                      text: 'Skip',
                      icon: FontAwesomeIcons.forward,
                      bgColor: blackColor,
                      borderColor: blackColor,
                      textIconColor: whiteColor,
                      isDisabled: isLoading,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
