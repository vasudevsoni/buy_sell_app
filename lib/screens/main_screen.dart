import 'package:flutter/material.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/utils.dart';
import 'home_screen.dart';
import '../screens/chats_screen.dart';
import 'my_ads_screen.dart';
import '../screens/selling/seller_categories_list_screen.dart';
import 'my_profile_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main-screen';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget currentScreen = const HomeScreen();
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ChatsScreen(),
    MyAdsScreen(),
    MyProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      extendBody: false,
      bottomNavigationBar: DotNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        enableFloatingNavBar: false,
        borderRadius: 10,
        enablePaddingAnimation: false,
        backgroundColor: greyColor,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        marginR: const EdgeInsets.all(0),
        paddingR: const EdgeInsets.all(0),
        items: [
          DotNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.house),
            selectedColor: blueColor,
            unselectedColor: fadedColor,
          ),
          DotNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.solidMessage),
            selectedColor: blueColor,
            unselectedColor: fadedColor,
          ),
          DotNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.solidHeart),
            selectedColor: blueColor,
            unselectedColor: fadedColor,
          ),
          DotNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.solidUser),
            selectedColor: blueColor,
            unselectedColor: fadedColor,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pushNamed(SellerCategoriesListScreen.routeName);
        },
        tooltip: 'Create a listing',
        backgroundColor: blueColor,
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }
}
