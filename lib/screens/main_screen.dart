import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import '../screens/chats_screen.dart';
import '../screens/profile_screen.dart';
import 'my_ads_screen.dart';
import '../screens/selling/seller_categories_list_screen.dart';

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
    ProfileScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 1,
        backgroundColor: greyColor,
        iconSize: 20,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: blueColor,
        unselectedItemColor: fadedColor,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'HOME',
            activeIcon: Icon(FontAwesomeIcons.house),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidMessage),
            activeIcon: Icon(FontAwesomeIcons.solidMessage),
            label: 'CHATS',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidHeart),
            activeIcon: Icon(FontAwesomeIcons.solidHeart),
            label: 'MY ADS',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidUser),
            activeIcon: Icon(FontAwesomeIcons.solidUser),
            label: 'MY PROFILE',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(SellerCategoriesListScreen.routeName);
        },
        backgroundColor: blueColor,
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }
}
