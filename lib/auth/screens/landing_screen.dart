import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/screens/web_view/privacy_policy_screen.dart';
import 'package:buy_sell_app/screens/web_view/terms_of_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';

import '/screens/main_screen.dart';
import '/widgets/custom_button_without_icon.dart';
import '../services/google_auth_service.dart';
import '../services/phone_auth_service.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import 'email_login_screen.dart';
import 'phone_auth_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int currentImage = 0;

  @override
  void initState() {
    getConnectivity();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        Get.offAll(() => const MainScreen(selectedIndex: 0));
      }
      return;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List images = [
      'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FHands%20-%20Exchange.svg?alt=media&token=bcc01462-9a38-4f32-8a17-51146abac817',
      'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FHands%20-%20Show.svg?alt=media&token=4bc3f85b-6c89-4eac-98e9-3fe707eb9982',
      'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FHands%20-%20Random%20Stuff.svg?alt=media&token=7403f58e-6a41-4c1a-a3d8-c89abe8a89ac',
      'https://firebasestorage.googleapis.com/v0/b/buy-sell-app-ff3ee.appspot.com/o/illustrations%2FHands%20-%20Phone.svg?alt=media&token=1cce8495-4c2c-452d-9a75-cbd110c9e733',
    ];

    List texts = [
      'Turn old stuff into money',
      'Discover quality products',
      'Chat instantly',
      'List without any limits',
    ];

    List subtitles = [
      'Make money by selling your old products',
      'Each listing is thoroughly reviewed by us',
      'Chat with buyers and sellers without hassle',
      'Listing a product is completely free, now and always',
    ];

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            CarouselSlider.builder(
              itemCount: images.length,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SvgPicture.network(
                            images[index],
                            fit: BoxFit.fitHeight,
                            placeholderBuilder: (context) {
                              return const Center(
                                child: SpinKitFadingCircle(
                                  color: greyColor,
                                  size: 20,
                                  duration: Duration(milliseconds: 1000),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        texts[index],
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      AutoSizeText(
                        subtitles[index],
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: lightBlackColor,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                viewportFraction: 1,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                initialPage: 0,
                scrollPhysics: const BouncingScrollPhysics(),
                reverse: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentImage = index;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((url) {
                int index = images.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.only(
                    left: 4,
                    right: 4,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImage == index ? blueColor : greyColor,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: whiteColor,
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Divider(
                            color: lightBlackColor,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Continue with",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: lightBlackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'Google',
                    icon: FontAwesomeIcons.google,
                    bgColor: whiteColor,
                    borderColor: lightBlackColor,
                    textIconColor: blackColor,
                    onPressed: () async {
                      User? user = await GoogleAuthentication.signinWithGoogle(
                        context,
                      );
                      if (user == null) {
                        return;
                      }
                      //login successful, add user to db and proceed
                      PhoneAuthService auth = PhoneAuthService();
                      auth.addUser(user);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Facebook',
                    icon: FontAwesomeIcons.facebook,
                    bgColor: whiteColor,
                    borderColor: lightBlackColor,
                    textIconColor: blackColor,
                    onPressed: () async {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Mobile',
                    icon: FontAwesomeIcons.phone,
                    bgColor: whiteColor,
                    borderColor: lightBlackColor,
                    textIconColor: blackColor,
                    onPressed: () => Get.to(
                      () => const PhoneAuthScreen(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Email',
                    icon: FontAwesomeIcons.solidEnvelope,
                    bgColor: whiteColor,
                    borderColor: lightBlackColor,
                    textIconColor: blackColor,
                    onPressed: () => Get.to(
                      () => const EmailLoginScreen(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                            text: 'By signing up, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.to(
                                  () => const TermsOfService(),
                                  transition: Transition.downToUp,
                                ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: blueColor,
                          ),
                        ),
                        const TextSpan(text: ' and'),
                        TextSpan(
                          text: ' Privacy Policy',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.to(
                                  () => const PrivacyPolicy(),
                                  transition: Transition.downToUp,
                                ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: blueColor,
                          ),
                        ),
                      ],
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
