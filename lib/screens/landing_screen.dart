import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../auth/services/google_auth_service.dart';
import '../auth/services/phone_auth_service.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../auth/screens/email_login_screen.dart';
import '../auth/screens/phone_auth_screen.dart';
import '../auth/screens/location_screen.dart';

class LandingScreen extends StatelessWidget {
  static const String routeName = '/landing-screen';
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      //if user not logged in, send him to landing page
      if (user == null) {
        return;
      }
      //if user is logged in, send him to location screen
      else {
        Navigator.pushReplacementNamed(context, LocationScreen.routeName);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 15,
              ),
              child: Text(
                'BestDeal - Buy & Sell Used Stuff',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  color: blackColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              color: greyColor,
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
              ),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Continue with Mobile',
                    icon: Iconsax.call5,
                    bgColor: blackColor,
                    borderColor: blackColor,
                    textIconColor: Colors.white,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      PhoneAuthScreen.routeName,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Continue with Email',
                    icon: Iconsax.login4,
                    bgColor: blueColor,
                    borderColor: blueColor,
                    textIconColor: Colors.white,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      EmailLoginScreen.routeName,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: 'Continue with Google',
                    icon: FontAwesomeIcons.google,
                    bgColor: Colors.white,
                    borderColor: blueColor,
                    textIconColor: blackColor,
                    onPressed: () async {
                      User? user = await GoogleAuthentication.signinWithGoogle(
                        context,
                      );
                      if (user != null) {
                        //login successful, add user to db and proceed
                        PhoneAuthService auth = PhoneAuthService();
                        // ignore: use_build_context_synchronously
                        auth.addUser(context, user);
                      } else {
                        return;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: Text(
                      'By continuing, you are accepting the Terms & conditions and Privacy policy.',
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: fadedColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
