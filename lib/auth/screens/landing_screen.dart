import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/auth/services/social_auth_service.dart';
import 'package:buy_sell_app/screens/web_view/privacy_policy_screen.dart';
import 'package:buy_sell_app/screens/web_view/terms_of_service.dart';
import 'package:buy_sell_app/widgets/loading_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/svg_picture.dart';
import '/widgets/custom_button_without_icon.dart';
import '../services/google_auth_service.dart';
import '/utils/utils.dart';
import '/widgets/custom_button.dart';
import 'email_login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isLoading = false;
  int currentImage = 0;

  @override
  void initState() {
    getConnectivity();
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
                  const Center(
                    child: Text(
                      'Network Connection Lost',
                      style: TextStyle(
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
                    child: const Text(
                      'Please check your internet connection',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List images = [
      'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fexchange.svg?alt=media&token=4634b16e-2db4-4823-b4c0-627ff396b057',
      'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fshow.svg?alt=media&token=bfebb25c-e57b-459c-ae9d-97027e2ca71d',
      'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fchat.svg?alt=media&token=5b60cd1b-d170-4934-a84a-0421179a8013',
      'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fphone.svg?alt=media&token=b10cbbcd-56ea-4f8c-8708-748a3abefad3',
      'https://firebasestorage.googleapis.com/v0/b/bechde-buy-sell.appspot.com/o/illustrations%2Fearth.svg?alt=media&token=3f0c3aac-ac37-4c65-8a42-174b2bd0b877',
    ];

    List texts = [
      'Turn old stuff into cash',
      'Find high-quality items',
      'Instant messaging',
      'Sell without limits',
      'Save the planet'
    ];

    List subtitles = [
      'Make money by selling gently used products',
      'Each listing is thoroughly reviewed by us',
      'Chat freely with buyers and sellers',
      'Listing a product is completely free, now and always',
      'Help the planet by reducing waste and supporting sustainable living'
    ];

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: size.width,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: CarouselSlider.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index, realIndex) {
                    return Column(
                      children: [
                        Expanded(
                          child: SVGPictureWidget(
                            url: images[index],
                            fit: BoxFit.fitHeight,
                            semanticsLabel: 'Landing screen pictures',
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        AutoSizeText(
                          texts[index],
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          subtitles[index],
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: lightBlackColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                    initialPage: 0,
                    autoPlay: true,
                    pauseAutoPlayInFiniteScroll: true,
                    pauseAutoPlayOnManualNavigate: true,
                    pauseAutoPlayOnTouch: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    scrollPhysics: const ClampingScrollPhysics(),
                    reverse: false,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentImage = index;
                      });
                    },
                  ),
                ),
              ),
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
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImage == index ? blueColor : greyColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: const [],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                        fontWeight: FontWeight.w500,
                        color: lightBlackColor,
                        fontSize: 10,
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
            isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: LoadingButton(
                      bgColor: greenColor,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomButton(
                      text: 'Google',
                      icon: Ionicons.logo_google,
                      bgColor: greenColor,
                      borderColor: greenColor,
                      textIconColor: whiteColor,
                      onPressed: () async {
                        if (mounted) {
                          setState(() {
                            isLoading = true;
                          });
                        }
                        User? user =
                            await GoogleAuthentication.signinWithGoogle();
                        //login successful, add user to db and proceed
                        if (user != null) {
                          final SocialAuthService auth = SocialAuthService();
                          await auth.addUser(user);
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                          return;
                        } else {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                          return;
                        }
                      },
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: LoadingButton(
                      bgColor: blackColor,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomButton(
                      text: 'Email',
                      icon: Ionicons.mail,
                      bgColor: blackColor,
                      borderColor: blackColor,
                      textIconColor: whiteColor,
                      onPressed: () => Get.to(
                        () => const EmailLoginScreen(),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'By signing up, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.to(
                              () => const TermsOfService(),
                              transition: Transition.downToUp,
                            ),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.to(
                              () => const PrivacyPolicy(),
                              transition: Transition.downToUp,
                            ),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
