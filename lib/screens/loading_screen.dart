import 'package:buy_sell_app/auth/screens/landing_screen.dart';
import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    //check whether user is logged in or not. Then navigate her accordingly.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Get.offAll(
          () => const MainScreen(selectedIndex: 0),
        );
      } else {
        Get.offAll(
          () => const LandingScreen(),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: SpinKitFadingCircle(
          color: lightBlackColor,
          size: 30,
          duration: Duration(milliseconds: 1000),
        ),
      ),
    );
  }
}
