import 'package:buy_sell_app/screens/search_field_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'auth/screens/email_register_screen.dart';
// import 'auth/screens/location_manual_screen.dart';
import 'error.dart';
import 'auth/screens/phone_auth_screen.dart';
import 'auth/screens/email_login_screen.dart';
import 'auth/screens/otp_screen.dart';
import 'auth/screens/forgot_password_screen.dart';
import 'auth/screens/location_screen.dart';
import 'screens/categories/categories_list_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/my_profile_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/selling/congratulations_screen.dart';
import 'screens/selling/seller_categories_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chats/my_chats_screen.dart';
import 'screens/my_favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/update_profile_image_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case MainScreen.routeName:
      return PageTransition(
        child: const MainScreen(),
        type: PageTransitionType.fade,
      );
    case HomeScreen.routeName:
      return PageTransition(
        child: const HomeScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case LandingScreen.routeName:
      return PageTransition(
        child: const LandingScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case EmailLoginScreen.routeName:
      return PageTransition(
        child: const EmailLoginScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case EmailRegisterScreen.routeName:
      return PageTransition(
        child: const EmailRegisterScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case ForgotPasswordScreen.routeName:
      return PageTransition(
        child: const ForgotPasswordScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case PhoneAuthScreen.routeName:
      return PageTransition(
        child: const PhoneAuthScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      final mobileNumber = settings.arguments as String;
      return PageTransition(
        child: OTPScreen(
          mobileNumber: mobileNumber,
          verificationId: verificationId,
        ),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case LocationScreen.routeName:
      return PageTransition(
        child: const LocationScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    // case LocationManualScreen.routeName:
    //   return MaterialPageRoute(
    //     builder: (context) => const LocationManualScreen(),
    //   );
    case CategoriesListScreen.routeName:
      return PageTransition(
        child: const CategoriesListScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case SellerCategoriesListScreen.routeName:
      return PageTransition(
        child: const SellerCategoriesListScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case CongratulationsScreen.routeName:
      return PageTransition(
        child: const CongratulationsScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case MyChatsScreen.routeName:
      return PageTransition(
        child: const MyChatsScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case SearchFieldScreen.routeName:
      return PageTransition(
        child: const SearchFieldScreen(),
        type: PageTransitionType.fade,
      );
    case MyFavoritesScreen.routeName:
      return PageTransition(
        child: const MyFavoritesScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case MyListingsScreen.routeName:
      return PageTransition(
        child: const MyListingsScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case SettingsScreen.routeName:
      return PageTransition(
        child: const SettingsScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case MyProfileScreen.routeName:
      return PageTransition(
        child: const MyProfileScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
    case UpdateProfileImageScreen.routeName:
      return PageTransition(
        child: const UpdateProfileImageScreen(),
        type: PageTransitionType.fade,
      );
    default:
      return PageTransition(
        child: const ErrorScreen(
          error: 'Uh-oh! Looks like you are lost in space!',
        ),
        type: PageTransitionType.rightToLeftWithFade,
      );
  }
}
