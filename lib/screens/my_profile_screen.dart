import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import 'landing_screen.dart';

class MyProfileScreen extends StatefulWidget {
  static const String routeName = '/my-profile-screen';
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: blueColor,
                radius: 50,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://img.icons8.com/fluency/48/000000/user-male-circle.png',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return const Icon(
                      FontAwesomeIcons.triangleExclamation,
                      size: 20,
                      color: redColor,
                    );
                  },
                  placeholder: (context, url) {
                    return const Center(
                      child: SpinKitFadingCube(
                        color: blueColor,
                        size: 30,
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
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
                bgColor: blackColor,
                borderColor: blackColor,
                textIconColor: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
