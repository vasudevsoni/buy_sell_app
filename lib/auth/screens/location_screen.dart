import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../../screens/main_screen.dart';

class LocationScreen extends StatefulWidget {
  static const String routeName = '/location-screen';

  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Location location = Location();
  late bool serviceEnabled;
  late PermissionStatus permissionGranted;
  late LocationData locationData;

  Future<LocationData?> getUserLocation() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    locationData = await location.getLocation();
    return locationData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Set your location to get best nearby product recommendations',
                textAlign: TextAlign.center,
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
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width * 0.9,
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
                Container(
                  margin: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: CustomButton(
                    text: 'Use my current location',
                    icon: FontAwesomeIcons.locationArrow,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: Colors.white,
                    onPressed: () {
                      getUserLocation().then((value) {
                        if (value != null) {
                          Navigator.pushReplacementNamed(
                            context,
                            MainScreen.routeName,
                          );
                        }
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
                    icon: FontAwesomeIcons.arrowRight,
                    bgColor: Colors.white,
                    borderColor: blueColor,
                    textIconColor: blackColor,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        MainScreen.routeName,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
