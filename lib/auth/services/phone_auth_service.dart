import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../utils/utils.dart';
import '../../auth/screens/otp_screen.dart';

class PhoneAuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  int? _resendToken;

  Future<void> signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
    required bool isResend,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        showSnackBar(
          context: context,
          content: 'Something has gone wrong. Please try again.',
          color: redColor,
        );
      },
      codeSent: ((String verificationId, int? resendToken) async {
        _resendToken = resendToken;
        if (isResend == false) {
          Get.to(
            () => OTPScreen(
              mobileNumber: phoneNumber,
              verificationId: verificationId,
            ),
          );
        }
      }),
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 2),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> addUser(context, User? user) async {
    final QuerySnapshot result =
        await users.where('uid', isEqualTo: user!.uid).get();
    List<DocumentSnapshot> document = result.docs;
    if (document.isNotEmpty) {
      //if user already exists in database, just navigate him
      Get.offAll(() => const MainScreen(selectedIndex: 0));
    } else {
      //if user does not exists in database, add him to db and then navigate
      try {
        return users.doc(user.uid).set({
          'uid': user.uid,
          'mobile': user.phoneNumber,
          'email': null,
          'name': 'BestDeal User',
          'bio': null,
          'location': null,
          'dateJoined': DateTime.now().millisecondsSinceEpoch,
          'dob': null,
          'profileImage': null,
        }).then((value) {
          Get.offAll(() => const MainScreen(selectedIndex: 0));
        });
      } on FirebaseAuthException catch (_) {
        showSnackBar(
          context: context,
          content: 'Something has gone wrong. Please try again.',
          color: redColor,
        );
      }
    }
  }
}
