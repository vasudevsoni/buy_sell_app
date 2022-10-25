import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../utils/utils.dart';
import 'home_screen.dart';
import 'chats/my_chats_screen.dart';
import 'my_favorites_screen.dart';
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
    MyChatsScreen(),
    MyFavoritesScreen(),
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
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BubbleBottomBar(
        opacity: .2,
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index!);
        },
        borderRadius: BorderRadius.circular(15),
        elevation: 0,
        fabLocation: BubbleBottomBarFabLocation.end,
        hasNotch: true,
        backgroundColor: greyColor,
        items: [
          BubbleBottomBarItem(
            backgroundColor: blueColor,
            icon: const Icon(
              Iconsax.home4,
              color: fadedColor,
            ),
            activeIcon: const Icon(
              Iconsax.home_15,
              color: blueColor,
            ),
            title: Text(
              "HOME",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: blueColor,
            icon: const Icon(
              Iconsax.message4,
              color: fadedColor,
            ),
            activeIcon: const Icon(
              Iconsax.message5,
              color: blueColor,
            ),
            title: Text(
              "CHATS",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: blueColor,
            icon: const Icon(
              Iconsax.heart4,
              color: fadedColor,
            ),
            activeIcon: const Icon(
              Iconsax.heart5,
              color: blueColor,
            ),
            title: Container(
              child: AutoSizeText(
                "FAVORITES",
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: blueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.menu,
              color: Colors.green,
            ),
            title: Text("Menu"),
          ),
        ],
      ),
      // AnimatedBottomNavigationBar(
      //   activeIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   gapLocation: GapLocation.center,
      //   iconSize: 25,
      //   height: 60,
      //   leftCornerRadius: 15,
      //   rightCornerRadius: 15,
      //   splashColor: blueColor,
      //   notchSmoothness: NotchSmoothness.softEdge,
      //   backgroundColor: greyColor,
      //   activeColor: blueColor,
      //   inactiveColor: fadedColor,
      //   splashRadius: 0,
      //   elevation: 0.0,
      //   icons: [
      //     _selectedIndex == 0 ? Iconsax.home_15 : Iconsax.home4,
      //     _selectedIndex == 1 ? Iconsax.message5 : Iconsax.message4,
      //     _selectedIndex == 2 ? Iconsax.heart5 : Iconsax.heart4,
      //     _selectedIndex == 3
      //         ? Iconsax.profile_circle5
      //         : Iconsax.profile_circle4,
      //   ],
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pushNamed(SellerCategoriesListScreen.routeName);
        },
        tooltip: 'List a product',
        enableFeedback: true,
        elevation: 0,
        backgroundColor: blueColor,
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }
}
