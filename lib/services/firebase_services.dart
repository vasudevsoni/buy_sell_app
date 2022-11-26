import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '/utils/utils.dart';

class FirebaseServices {
  final User? user = FirebaseAuth.instance.currentUser;
  final Uuid uuid = const Uuid();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  final CollectionReference listings =
      FirebaseFirestore.instance.collection('listings');

  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');

  final CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');

  Future<DocumentSnapshot> getCurrentUserData() async {
    final DocumentSnapshot doc = await users.doc(user!.uid).get();
    return doc;
  }

  Future<DocumentSnapshot> getUserData(id) async {
    final DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<DocumentSnapshot> getProductDetails(String id) async {
    final DocumentSnapshot doc = await listings.doc(id).get();
    return doc;
  }

  updateUserDetails(
    id,
    Map<String, dynamic> data,
  ) async {
    try {
      await users.doc(id).update(data);
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  createChatRoomInFirebase({chatData}) async {
    try {
      await chats.doc(chatData['chatRoomId']).set(chatData);
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  sendChat({chatRoomId, message}) async {
    try {
      await chats.doc(chatRoomId).collection('messages').add(message);
      await chats.doc(chatRoomId).update({
        'lastChat': message['message'],
        'lastChatTime': message['time'],
        'read': false,
      });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  updateFavorite({isLiked, productId}) async {
    try {
      if (!isLiked) {
        await listings.doc(productId).update({
          'favorites': FieldValue.arrayRemove([user!.uid])
        }).then((value) {
          showSnackBar(
            content: 'Removed from favorites',
            color: redColor,
          );
        });
        return;
      }
      await listings.doc(productId).update({
        'favorites': FieldValue.arrayUnion([user!.uid])
      }).then((value) {
        showSnackBar(
          content: 'Added to favorites',
          color: blueColor,
        );
      });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  followUser({currentUserId, userId, isFollowed}) async {
    try {
      if (!isFollowed) {
        await users.doc(userId).update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
        await users.doc(currentUserId).update({
          'following': FieldValue.arrayRemove([userId])
        });
        return;
      }
      await users.doc(userId).update({
        'followers': FieldValue.arrayUnion([currentUserId])
      });
      await users.doc(currentUserId).update({
        'following': FieldValue.arrayUnion([userId])
      });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  markAsSold({productId}) async {
    try {
      await listings.doc(productId).update({
        'isActive': false,
        'isSold': true,
      }).then((value) {
        showSnackBar(
          content: 'The product has been marked as sold',
          color: blueColor,
        );
      });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  promoteListingToTop({listingId}) async {
    try {
      await listings.doc(listingId).update({
        'postedAt': DateTime.now().millisecondsSinceEpoch,
      }).then((value) {
        showSnackBar(
          content: 'Listing succesfully boosted to top',
          color: blueColor,
        );
      });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  deleteChat({chatRoomId}) async {
    try {
      await chats.doc(chatRoomId).delete().then((value) {
        showSnackBar(
          content: 'Chat deleted successfully',
          color: redColor,
        );
      });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  deleteListingImage({
    listingId,
    required String imageUrl,
  }) async {
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    try {
      await storageRef.delete();
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  deleteListing({listingId}) async {
    List<String> images = [];
    List<dynamic> chatsToDelete = [];
    try {
      await listings.doc(listingId.toString()).get().then((value) {
        for (int i = 0; i < value['images'].length; i++) {
          images.add(value['images'][i].toString());
        }
      });
      for (var link in images) {
        await deleteListingImage(
          listingId: listingId,
          imageUrl: link,
        );
      }
      await chats
          .where('product.productId', isEqualTo: listingId)
          .get()
          .then((value) {
        for (var element in value.docs) {
          chatsToDelete.add(element.id);
        }
      });
      for (var chatRoomId in chatsToDelete) {
        await deleteChat(chatRoomId: chatRoomId.toString());
      }
      await listings.doc(listingId.toString()).delete().then((value) {
        showSnackBar(
          content: 'Product has been deleted',
          color: redColor,
        );
      });
    } on FirebaseAuthException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  submitFeedback({
    text,
    model,
    androidVersion,
    securityPatch,
  }) async {
    try {
      final id = uuid.v4();
      await reports.doc(id).set({
        'type': 'feedback',
        'userId': user!.uid,
        'text': text,
        'postedAt': DateTime.now().toLocal().toString(),
        'model': model,
        'androidVersion': androidVersion,
        'securityPatch': securityPatch,
      });
      showSnackBar(
        content: 'Feedback submitted. Thank you so much for your effort',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  reportAProblem({
    text,
    model,
    androidVersion,
    securityPatch,
    screenshot,
  }) async {
    final id = uuid.v4();
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('reportImages/${user!.uid}/$id');
      final UploadTask uploadTask = storageReference.putFile(screenshot);
      final String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      await reports.doc(id).set({
        'type': 'screenshotReport',
        'userId': user!.uid,
        'text': text,
        'screenshot': downloadUrl,
        'postedAt': DateTime.now().toLocal().toString(),
        'model': model,
        'androidVersion': androidVersion,
        'securityPatch': securityPatch,
        'isResolved': false,
      });
      showSnackBar(
        content: 'Report submitted. We will look into it as soon as possible',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  reportItem({listingId, message}) async {
    final id = uuid.v4();
    try {
      await reports.doc(id).set({
        'type': 'productReport',
        'productId': listingId,
        'userUid': user!.uid,
        'message': message,
        'postedAt': DateTime.now().toLocal().toString(),
        'isResolved': false,
      });
      showSnackBar(
        content: 'Product reported. We will look into it as soon as possible',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  reportUser({userId, message}) async {
    final id = uuid.v4();
    try {
      await reports.doc(id).set({
        'type': 'userReport',
        'reporterId': user!.uid,
        'userUid': userId,
        'message': message,
        'postedAt': DateTime.now().toLocal().toString(),
        'isResolved': false,
      });
      showSnackBar(
        content: 'User reported. We will look into it as soon as possible',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  // Future<String> createDynamicLink() async {
  //   final dynamicLinkParams = DynamicLinkParameters(
  //     link: Uri.parse("https://sites.google.com/view/buy-sell-app/home/"),
  //     uriPrefix: "https://vasudevsoni.page.link",
  //     androidParameters: const AndroidParameters(
  //       packageName: "com.bechde.buy_sell_app",
  //       minimumVersion: 0,
  //     ),
  //   );

  //   final dynamicLink =
  //       await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
  //   return dynamicLink.shortUrl.toString();
  // }

  // Future initDynamicLink() async {
  //   final PendingDynamicLinkData? data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   _handleDeepLink(data);

  //   FirebaseDynamicLinks.instance.onLink
  //       .listen((PendingDynamicLinkData dynamicLinkData) async {
  //     _handleDeepLink(dynamicLinkData);
  //   }).onError((e) {
  //     log('Something has gone wrong: $e');
  //   });
  // }

  // void _handleDeepLink(PendingDynamicLinkData? data) {
  //   final Uri deepLink = data!.link;
  //   log(deepLink.toString());
  // }
}
