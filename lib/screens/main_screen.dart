import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../auth/screens/email_verification_screen.dart';
import '../auth/screens/location_screen.dart';
import '../provider/providers.dart';
import '../services/firebase_services.dart';
import '/widgets/custom_button_without_icon.dart';
import '/utils/utils.dart';
import 'chats/my_chats_screen.dart';
import 'home_screen.dart';
import 'my_favorites_screen.dart';
import 'my_profile_screen.dart';
import 'selling/seller_categories_list_screen.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, required this.selectedIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseServices _services = FirebaseServices();
  final User? user = FirebaseAuth.instance.currentUser;
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  showNetworkError() {
    showModalBottomSheet(
      context: context,
      backgroundColor: transparentColor,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: false,
      builder: (context) {
        return SafeArea(
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
                Center(
                  child: Text(
                    'Network Connection Lost',
                    style: GoogleFonts.interTight(
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
                  child: Text(
                    'Please check your internet connection',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
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
        );
      },
    );
  }

  Future<void> getConnectivity() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && !isAlertSet) {
        showNetworkError();
        setState(() => isAlertSet = true);
      }
    });
  }

  Future<void> onSellButtonClicked() async {
    final userData = await _services.getCurrentUserData();
    if (userData['location'] != null) {
      Get.to(
        () => const SellerCategoriesListScreen(),
      );
    } else {
      Get.to(() => const LocationScreen(isOpenedFromSellButton: true));
      showSnackBar(
        content: 'Please set your location to sell products',
        color: redColor,
      );
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, AppNavigationProvider>(
      builder: (context, locationProv, mainProv, child) {
        final int selectedIndex = mainProv.currentPageIndex;

        final List<Widget> pages = [
          HomeScreen(
            locationData: locationProv.locationData,
          ),
          const MyChatsScreen(),
          const MyFavoritesScreen(),
          const MyProfileScreen(),
        ];

        const List<IconData> iconsList = [
          Ionicons.home_outline,
          Ionicons.chatbox_ellipses_outline,
          Ionicons.heart_outline,
          Ionicons.person_circle_outline,
        ];

        const List<IconData> selectedIconsList = [
          Ionicons.home,
          Ionicons.chatbox_ellipses,
          Ionicons.heart,
          Ionicons.person_circle,
        ];

        const List<String> titlesList = [
          'Home',
          'Chats',
          'Favorites',
          'Profile',
        ];

        void onItemTapped(int index) {
          mainProv.switchToPage(index);
        }

        void onFloatingActionButtonPressed() {
          if (!user!.emailVerified &&
              user!.providerData[0].providerId == 'password') {
            Get.to(() => const EmailVerificationScreen());
          } else {
            onSellButtonClicked();
          }
        }

        return Scaffold(
          backgroundColor: whiteColor,
          body: IndexedStack(
            index: selectedIndex,
            children: pages,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: blueColor,
            elevation: 0,
            tooltip: 'List a product',
            enableFeedback: true,
            onPressed: () => onFloatingActionButtonPressed(),
            child: const Center(
              child: Icon(
                Ionicons.add,
                size: 30,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            onTap: onItemTapped,
            gapLocation: GapLocation.center,
            activeIndex: selectedIndex,
            backgroundColor: whiteColor,
            blurEffect: true,
            height: 55,
            leftCornerRadius: 10,
            rightCornerRadius: 10,
            notchSmoothness: NotchSmoothness.defaultEdge,
            splashColor: transparentColor,
            itemCount: pages.length,
            tabBuilder: (index, isActive) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedIndex == index
                        ? selectedIconsList[index]
                        : iconsList[index],
                    size: 24,
                    color: selectedIndex == index ? blueColor : lightBlackColor,
                  ),
                  AutoSizeText(
                    titlesList[index],
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          selectedIndex == index ? blueColor : lightBlackColor,
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}
