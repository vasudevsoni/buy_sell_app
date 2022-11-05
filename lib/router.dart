import 'package:flutter/material.dart';

import 'auth/screens/email_register_screen.dart';
import 'auth/screens/email_verification_screen.dart';
import 'error.dart';
import 'auth/screens/phone_auth_screen.dart';
import 'auth/screens/email_login_screen.dart';
import 'auth/screens/otp_screen.dart';
import 'auth/screens/forgot_password_screen.dart';
import 'screens/categories/categories_list_screen.dart';
import 'screens/search_field_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/my_profile_screen.dart';
import 'screens/selling/congratulations_screen.dart';
import 'screens/selling/seller_categories_list_screen.dart';
import 'auth/screens/landing_screen.dart';
import 'screens/chats/my_chats_screen.dart';
import 'screens/my_favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/update_profile_image_screen.dart';
import 'screens/update_profile_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LandingScreen.routeName:
      return MaterialPageRoute(builder: (_) => const LandingScreen());
    case EmailLoginScreen.routeName:
      return MaterialPageRoute(builder: (_) => const EmailLoginScreen());
    case EmailRegisterScreen.routeName:
      return MaterialPageRoute(builder: (_) => const EmailRegisterScreen());
    case EmailVerificationScreen.routeName:
      return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
    case ForgotPasswordScreen.routeName:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
    case PhoneAuthScreen.routeName:
      return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      final mobileNumber = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => OTPScreen(
          mobileNumber: mobileNumber,
          verificationId: verificationId,
        ),
      );
    case CategoriesListScreen.routeName:
      return MaterialPageRoute(builder: (_) => const CategoriesListScreen());
    case SellerCategoriesListScreen.routeName:
      return MaterialPageRoute(
          builder: (_) => const SellerCategoriesListScreen());
    case CongratulationsScreen.routeName:
      return MaterialPageRoute(builder: (_) => const CongratulationsScreen());
    case MyChatsScreen.routeName:
      return MaterialPageRoute(builder: (_) => const MyChatsScreen());
    case SearchFieldScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SearchFieldScreen());
    case MyFavoritesScreen.routeName:
      return MaterialPageRoute(builder: (_) => const MyFavoritesScreen());
    case MyListingsScreen.routeName:
      return MaterialPageRoute(builder: (_) => const MyListingsScreen());
    case SettingsScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case MyProfileScreen.routeName:
      return MaterialPageRoute(builder: (_) => const MyProfileScreen());
    case UpdateProfileScreen.routeName:
      return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());
    case UpdateProfileImageScreen.routeName:
      return MaterialPageRoute(
          builder: (_) => const UpdateProfileImageScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => const ErrorScreen(
          error: 'Uh-oh! Looks like you are lost in space!',
        ),
      );
  }
}
