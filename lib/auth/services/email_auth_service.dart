import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../utils/utils.dart';

class EmailAuthService {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> loginUser({
    context,
    email,
    password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Get.offAll(() => const MainScreen(selectedIndex: 0));
      });
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
          context: context,
          content: 'Account does not exist. Please create one.',
          color: redColor,
        );
      } else if (e.code == 'wrong-password') {
        showSnackBar(
          context: context,
          content: 'Email or password is incorrect. Please try again.',
          color: redColor,
        );
      }
    }
  }

  Future<void> registerUser({
    context,
    name,
    email,
    password,
    isLog,
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
        'dateJoined': DateTime.now().millisecondsSinceEpoch,
        'dob': null,
        'profileImage': null,
      }).then((value) async {
        //send to main screen
        Get.offAll(() => const MainScreen(selectedIndex: 0));
      });
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(
          context: context,
          content:
              'Password is weak. Please try a combination of numbers, letters and special characters.',
          color: redColor,
        );
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(
          context: context,
          content: 'An account with this email already exists. Please log in.',
          color: redColor,
        );
      }
    }
  }
}
