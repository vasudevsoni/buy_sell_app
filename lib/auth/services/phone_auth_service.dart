import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/utils.dart';
import '../../auth/screens/otp_screen.dart';
import '../../auth/screens/location_screen.dart';

class PhoneAuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        showSnackBar(
          context: context,
          content: e.message!,
        );
      },
      codeSent: ((String verificationId, int? resendToken) async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              mobileNumber: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      }),
      timeout: const Duration(seconds: 2),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> addUser(context, user) async {
    final QuerySnapshot result =
        await users.where('uid', isEqualTo: user.uid).get();
    List<DocumentSnapshot> document = result.docs;

    if (document.isNotEmpty) {
      //if user already exists in databse, just navigate him
      Navigator.pushReplacementNamed(context, LocationScreen.routeName);
    } else {
      //if user does not exists in database, add him to db and then navigate
      return users.doc(user.uid).set({
        'uid': user.uid,
        'mobile': user.phoneNumber,
        'email': null,
        'name': null,
        'location': null,
        'dateJoined': DateTime.now().millisecondsSinceEpoch,
      }).then((value) {
        Navigator.pushReplacementNamed(context, LocationScreen.routeName);
      }).catchError(
        // ignore: invalid_return_type_for_catch_error
        (err) => showSnackBar(
          context: context,
          content: 'Some error occurred. Please try again.',
        ),
      );
    }
  }
}
