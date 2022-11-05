import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:buy_sell_app/screens/my_profile_screen.dart';
import 'package:buy_sell_app/widgets/custom_button_without_icon.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:provider/provider.dart';

import '../provider/location_provider.dart';
import '../utils/utils.dart';
import 'home_screen.dart';
import 'chats/my_chats_screen.dart';
import 'my_favorites_screen.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, required this.selectedIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int _selectedIndex = 0;

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    getConnectivity();
    setState(() {
      _selectedIndex = widget.selectedIndex;
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
    final locationProv = Provider.of<LocationProvider>(context);
    List<Widget> pages = <Widget>[
      HomeScreen(
        locationData: locationProv.locationData,
      ),
      const MyChatsScreen(),
      const MyFavoritesScreen(),
      const MyProfileScreen(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        activeIndex: _selectedIndex,
        onTap: _onItemTapped,
        gapLocation: GapLocation.none,
        iconSize: 25,
        height: 60,
        notchSmoothness: NotchSmoothness.defaultEdge,
        backgroundColor: greyColor,
        activeColor: blackColor,
        inactiveColor: lightBlackColor,
        splashRadius: 0,
        elevation: 0.0,
        icons: [
          _selectedIndex == 0
              ? FontAwesomeIcons.solidCompass
              : FontAwesomeIcons.compass,
          _selectedIndex == 1
              ? FontAwesomeIcons.solidComment
              : FontAwesomeIcons.comment,
          _selectedIndex == 2
              ? FontAwesomeIcons.solidHeart
              : FontAwesomeIcons.heart,
          _selectedIndex == 3
              ? FontAwesomeIcons.solidCircleUser
              : FontAwesomeIcons.circleUser
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: NeumorphicFloatingActionButton(
      //   onPressed: onButtonClicked,
      //   tooltip: 'List a product',
      //   style: NeumorphicStyle(
      //     lightSource: LightSource.top,
      //     shape: NeumorphicShape.convex,
      //     depth: 2,
      //     intensity: 0.2,
      //     color: blueColor,
      //     boxShape: NeumorphicBoxShape.roundRect(
      //       BorderRadius.circular(50),
      //     ),
      //   ),
      //   child: const Icon(
      //     FontAwesomeIcons.plus,
      //     color: whiteColor,
      //   ),
      // ),
    );
  }
}
