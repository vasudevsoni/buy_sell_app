import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'BestDeal - Buy & Sell Used Stuff',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * 0.9,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://previews.123rf.com/images/mykate/mykate1702/mykate170200215/72113541-hand-drawn-vector-illustrations-save-money-doodle-design-elements-money-finance-payments-banks-cash-.jpg',
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: CustomButton(
                  text: 'Continue with Mobile',
                  icon: FontAwesomeIcons.phone,
                  bgColor: blackColor,
                  textIconColor: Colors.white,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    PhoneAuthScreen.routeName,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: CustomButton(
                  text: 'Continue with Email',
                  icon: FontAwesomeIcons.solidEnvelope,
                  bgColor: blueColor,
                  textIconColor: Colors.white,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    EmailLoginScreen.routeName,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: CustomButton(
                  text: 'Continue with Google',
                  icon: FontAwesomeIcons.google,
                  bgColor: Colors.white,
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
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
