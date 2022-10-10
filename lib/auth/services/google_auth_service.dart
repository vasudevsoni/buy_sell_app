import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthentication {
  static Future<User?> signinWithGoogle(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        UserCredential result = await auth.signInWithCredential(authCredential);
        user = result.user;
      } on FirebaseAuthException catch (err) {
        if (err.code == 'account-exists-with-different-credential') {
          showSnackBar(
            context: context,
            content: 'Account exists with different sign in method.',
          );
        } else if (err.code == 'invalid-credentials') {
          showSnackBar(
            context: context,
            content: 'Invalid credentials. Please try again.',
          );
        }
      } catch (e) {
        showSnackBar(
          context: context,
          content: 'Some error occurred. Please try again.',
        );
      }
    }
    return user;
  }
}