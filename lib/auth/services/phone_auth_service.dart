// class PhoneAuthService {
  // FirebaseAuth auth = FirebaseAuth.instance;
  // CollectionReference users = FirebaseFirestore.instance.collection('users');

  // int? _resendToken;
  // Future<void> signInWithPhone({
  //   required BuildContext context,
  //   required String phoneNumber,
  //   required bool isResend,
  // }) async {
  //   await auth.verifyPhoneNumber(
  //     phoneNumber: phoneNumber,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await auth.signInWithCredential(credential);
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       showSnackBar(
  //         content: 'Something has gone wrong. Please try again',
  //         color: redColor,
  //       );
  //     },
  //     codeSent: ((String verificationId, int? resendToken) async {
  //       _resendToken = resendToken;
  //       if (!isResend) {
  //         Get.to(
  //           () => OTPScreen(
  //             mobileNumber: phoneNumber,
  //             verificationId: verificationId,
  //           ),
  //         );
  //       }
  //     }),
  //     forceResendingToken: _resendToken,
  //     timeout: const Duration(seconds: 2),
  //     codeAutoRetrievalTimeout: (String verificationId) {},
  //   );
  // }

  // Future<void> addUser(User? user) async {
  //   final QuerySnapshot result =
  //       await users.where('uid', isEqualTo: user!.uid).get();
  //   List<DocumentSnapshot> document = result.docs;
  //   //if user does not exists in database, add her and then navigate to main screen
  //   if (document.isEmpty) {
  //     try {
  //       return users.doc(user.uid).set({
  //         'uid': user.uid,
  //         'mobile': user.phoneNumber,
  //         'email': null,
  //         'name': 'BechDe User',
  //         'bio': null,
  //         'location': null,
  //         'dateJoined': DateTime.now().millisecondsSinceEpoch,
  //         'profileImage': null,
  //         'followers': [],
  //         'following': [],
  //       }).then((value) {
  //         Get.offAll(() => const MainScreen(selectedIndex: 0));
  //       });
  //     } on FirebaseAuthException catch (_) {
  //       showSnackBar(
  //         content: 'Something has gone wrong. Please try again',
  //         color: redColor,
  //       );
  //     }
  //     return;
  //   }
  //   //if user already exists in database, just navigate her to main screen
  //   Get.offAll(() => const MainScreen(selectedIndex: 0));
  // }
// }
