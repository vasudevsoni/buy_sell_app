import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../screens/main_screen.dart';
import '../../utils/utils.dart';

class SocialAuthService {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUser(User? user) async {
    final QuerySnapshot result =
        await _users.where('uid', isEqualTo: user!.uid).get();
    final List<DocumentSnapshot> document = result.docs;
    //if user does not exists in database, add her and then navigate to main screen
    if (document.isEmpty) {
      try {
        await _users.doc(user.uid).set({
          'uid': user.uid,
          'mobile': null,
          'email': user.providerData[0].email,
          'name': user.displayName,
          'bio': null,
          'location': null,
          'rating': 0,
          'ratedBy': {''},
          'dateJoined': DateTime.now().millisecondsSinceEpoch,
          'profileImage': user.photoURL,
          'instagramLink': null,
          'facebookLink': null,
          'websiteLink': null,
          'isDisabled': false,
          'Fcm_token': '',
          // 'followers': [],
          // 'following': [],
        });
        Get.offAll(() => const MainScreen(selectedIndex: 0));
        return;
      } on FirebaseAuthException catch (_) {
        showSnackBar(
          content: 'Something has gone wrong. Please try again',
          color: redColor,
        );
        return;
      }
    }
    //if user already exists in database, just navigate her to main screen
    if (document.isNotEmpty) {
      await _users.doc(user.uid).update({
        'Fcm_token': '',
      });
      Get.offAll(() => const MainScreen(selectedIndex: 0));
      return;
    }
  }
}
