import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/screens/location_screen.dart';
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
          //login success. Navigate to location screen.
          .then((value) {
        Navigator.of(context).pushReplacementNamed(LocationScreen.routeName);
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
      //register success. add user to db and navigate to location screen.
      users.doc(userCredential.user!.uid).set({
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
        //send email verification and navigate to verification screen
        await userCredential.user!.sendEmailVerification().then((value) {
          Navigator.of(context).pushReplacementNamed(LocationScreen.routeName);
        });
      });
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(
          context: context,
          content: 'Password too weak. Try again.',
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
