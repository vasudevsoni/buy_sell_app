import 'package:flutter/material.dart';

import 'auth/screens/email_register_screen.dart';
// import 'auth/screens/location_manual_screen.dart';
import 'error.dart';
import 'auth/screens/phone_auth_screen.dart';
import 'auth/screens/email_login_screen.dart';
import 'auth/screens/otp_screen.dart';
import 'auth/screens/forgot_password_screen.dart';
import 'auth/screens/location_screen.dart';
import 'screens/categories/categories_list_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/selling/congratulations_screen.dart';
import 'screens/selling/seller_categories_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_ads_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case MainScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const MainScreen(),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case LandingScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LandingScreen(),
      );
    case EmailLoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const EmailLoginScreen(),
      );
    case EmailRegisterScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const EmailRegisterScreen(),
      );
    case ForgotPasswordScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      );
    case PhoneAuthScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const PhoneAuthScreen(),
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      final mobileNumber = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
          mobileNumber: mobileNumber,
        ),
      );
    case LocationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LocationScreen(),
      );
    // case LocationManualScreen.routeName:
    //   return MaterialPageRoute(
    //     builder: (context) => const LocationManualScreen(),
    //   );
    case CategoriesListScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CategoriesListScreen(),
      );
    case SellerCategoriesListScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SellerCategoriesListScreen(),
      );
    case CongratulationsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CongratulationsScreen(),
      );
    case ProductDetailsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ProductDetailsScreen(),
      );
    case ChatsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ChatsScreen(),
      );
    case MyAdsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const MyAdsScreen(),
      );
    case ProfileScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: 'Uh-oh! Looks like you are lost in space!'),
        ),
      );
  }
}
