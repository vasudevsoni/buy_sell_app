import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '/utils/utils.dart';

class GoogleAuthentication {
  static Future<User?> signinWithGoogle() async {
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
        final UserCredential result =
            await auth.signInWithCredential(authCredential);
        user = result.user;
      } on FirebaseAuthException catch (err) {
        if (err.code == 'account-exists-with-different-credential') {
          showSnackBar(
            content: 'Account already exists with a different sign in method',
            color: redColor,
          );
        }
        if (err.code == 'invalid-credentials') {
          showSnackBar(
            content: 'Invalid credentials. Please try again',
            color: redColor,
          );
        }
      } catch (e) {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
      }
    }
    return user;
  }
}
