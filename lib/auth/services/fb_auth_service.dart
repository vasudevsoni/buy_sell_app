// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// import '/utils/utils.dart';

// class FbAuthentication {
//   static Future<User?> signInWithFb() async {
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     User? user;
//     final LoginResult loginResult = await FacebookAuth.instance.login();
//     try {
//       if (loginResult.status == LoginStatus.success) {
//         final OAuthCredential authCredential = FacebookAuthProvider.credential(
//           loginResult.accessToken!.token,
//         );

//         final UserCredential result =
//             await auth.signInWithCredential(authCredential);
//         user = result.user;
//       } else {
//         // User cancelled sign in
//         return null;
//       }
//     } on FirebaseAuthException catch (err) {
//       // Handle specific Firebase Authentication errors
//       if (err.code == 'account-exists-with-different-credential') {
//         showSnackBar(
//           content: 'Account already exists with a different sign in method',
//           color: redColor,
//         );
//       } else if (err.code == 'invalid-credentials') {
//         showSnackBar(
//           content: 'Invalid credentials. Please try again',
//           color: redColor,
//         );
//       } else if (err.code == 'user-disabled') {
//         showSnackBar(
//           content: 'Your account has been disabled.',
//           color: redColor,
//         );
//       } else {
//         showSnackBar(
//           content: 'Something has gone wrong. Please try again',
//           color: redColor,
//         );
//       }
//     } catch (e) {
//       // Handle other errors
//       showSnackBar(
//         content: 'Something has gone wrong. Please try again',
//         color: redColor,
//       );
//     }
//     return user;
//   }
// }
