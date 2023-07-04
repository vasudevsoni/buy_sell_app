import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '/screens/main_screen.dart';
import '/utils/utils.dart';

class EmailAuthService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static const String weakPasswordError =
      'Password is weak. Please try a combination of numbers, letters and special characters';
  static const String emailAlreadyInUseError =
      'An account with this email already exists. Please log in';
  static const String accountNotExistError =
      'Account does not exist. Please create one';
  static const String incorrectEmailOrPasswordError =
      'Email or password is incorrect. Please try again';
  static const String somethingWentWrongError =
      'Something has gone wrong. Please try again';

  Future<void> loginUser({
    context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAll(() => const MainScreen(selectedIndex: 0));
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
          content: accountNotExistError,
          color: redColor,
        );
      }
      if (e.code == 'wrong-password') {
        showSnackBar(
          content: incorrectEmailOrPasswordError,
          color: redColor,
        );
      } else {
        showSnackBar(
          content: somethingWentWrongError,
          color: redColor,
        );
      }
    }
  }

  Future<void> registerUser({
    context,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //register success. add user to db
      await users.doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'mobile': null,
        'email': userCredential.user!.email,
        'name': name,
        'bio': null,
        'location': null,
        'rating': 0,
        'ratedBy': {''},
        'dateJoined': DateTime.now().millisecondsSinceEpoch,
        'profileImage': null,
        'instagramLink': null,
        'facebookLink': null,
        'websiteLink': null,
        'isDisabled': false,
        // 'followers': [],
        // 'following': [],
      });
      //send to main screen
      Get.offAll(() => const MainScreen(selectedIndex: 0));
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(
          content: weakPasswordError,
          color: redColor,
        );
      }
      if (e.code == 'email-already-in-use') {
        showSnackBar(
          content: emailAlreadyInUseError,
          color: redColor,
        );
      } else {
        showSnackBar(
          content: somethingWentWrongError,
          color: redColor,
        );
      }
    }
  }
}
