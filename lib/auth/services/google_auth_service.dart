import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '/utils/utils.dart';

class GoogleAuthentication {
  static Future<User?> signInWithGoogle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    try {
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential result =
            await auth.signInWithCredential(authCredential);
        user = result.user;
      } else {
        // User cancelled sign in
        return null;
      }
    } on FirebaseAuthException catch (err) {
      // Handle specific Firebase Authentication errors
      if (err.code == 'account-exists-with-different-credential') {
        showSnackBar(
          content: 'Account already exists with a different sign in method',
          color: redColor,
        );
      } else if (err.code == 'invalid-credentials') {
        showSnackBar(
          content: 'Invalid credentials. Please try again',
          color: redColor,
        );
      } else {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
      }
    } catch (e) {
      // Handle other errors
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
    return user;
  }
}
