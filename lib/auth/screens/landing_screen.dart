import 'dart:async';

import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/widgets/custom_button_without_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../services/google_auth_service.dart';
import '../services/phone_auth_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import 'email_login_screen.dart';
import 'phone_auth_screen.dart';

class LandingScreen extends StatefulWidget {
  static const String routeName = '/landing-screen';
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    getConnectivity();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        return;
      } else {
        if (mounted) {
          Get.offAll(() => const MainScreen(
                selectedIndex: 0,
              ));
        }
      }
    });
    super.initState();
  }

  showDialogBox() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            title: Text(
              'No Connection',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700, color: redColor),
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
                'Please check your internet connection',
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
                text: 'OK',
                onPressed: () async {
                  Get.back();
                  setState(() {
                    isAlertSet = false;
                  });
                  isDeviceConnected =
                      await InternetConnectionChecker().hasConnection;
                  if (!isDeviceConnected) {
                    showDialogBox();
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
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1511556820780-d912e42b4980?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZHVjdHN8ZW58MHx8MHx8&w=1000&q=80',
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                return const Icon(
                  FontAwesomeIcons.circleExclamation,
                  size: 30,
                  color: redColor,
                );
              },
              placeholder: (context, url) {
                return const Center(
                  child: SpinKitFadingCube(
                    color: lightBlackColor,
                    size: 30,
                    duration: Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login to BestDeal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: blackColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: 'Login with Phone',
                    icon: FontAwesomeIcons.phone,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: whiteColor,
                    onPressed: () => Get.toNamed(PhoneAuthScreen.routeName),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Login with google',
                    icon: FontAwesomeIcons.google,
                    bgColor: googleLoginColor,
                    borderColor: googleLoginColor,
                    textIconColor: whiteColor,
                    onPressed: () async {
                      User? user = await GoogleAuthentication.signinWithGoogle(
                        context,
                      );
                      if (user != null) {
                        //login successful, add user to db and proceed
                        PhoneAuthService auth = PhoneAuthService();
                        // ignore: use_build_context_synchronously
                        auth.addUser(context, user);
                      } else {
                        return;
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                            child: Divider(
                          color: blackColor,
                        )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "OR",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(
                          color: blackColor,
                        )),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'Login with email',
                    icon: FontAwesomeIcons.solidEnvelope,
                    bgColor: greyColor,
                    borderColor: greyColor,
                    textIconColor: blackColor,
                    onPressed: () => Get.toNamed(EmailLoginScreen.routeName),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
