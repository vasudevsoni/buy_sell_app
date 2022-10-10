import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/custom_button.dart';
import 'landing_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile-screen';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomButton(
          text: 'Log out',
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.pushReplacementNamed(
                context,
                LandingScreen.routeName,
              );
            });
          },
          icon: FontAwesomeIcons.rightFromBracket,
          bgColor: Colors.black,
          textIconColor: Colors.white,
        ),
      ),
    );
  }
}
