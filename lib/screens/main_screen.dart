import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '/provider/main_provider.dart';
import '/widgets/custom_button_without_icon.dart';
import '/provider/location_provider.dart';
import '/utils/utils.dart';
import 'my_profile_screen.dart';
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
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

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
    final locationProv = Provider.of<LocationProvider>(context);
    final mainProv = Provider.of<MainProvider>(context);
    int selectedIndex = mainProv.currentPageIndex;

    final pages = [
      HomeScreen(
        locationData: locationProv.locationData,
      ),
      const MyChatsScreen(),
      const MyFavoritesScreen(),
      const MyProfileScreen(),
    ];

    onItemTapped(int index) {
      mainProv.switchToPage(index);
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: blackColor,
        unselectedItemColor: fadedColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 25,
        elevation: 0,
        backgroundColor: greyColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home_outline),
            activeIcon: Icon(Ionicons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.chatbubbles_outline),
            activeIcon: Icon(Ionicons.chatbubbles),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Ionicons.heart_outline,
            ),
            activeIcon: Icon(
              Ionicons.heart,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_circle_outline),
            activeIcon: Icon(Ionicons.person_circle),
            label: '',
          ),
        ],
      ),
    );
  }
}
