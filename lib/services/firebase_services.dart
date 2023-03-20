import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '/utils/utils.dart';
import 'cloudinary_services.dart';

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

  Future<void> updateUserDetails(
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

  Future<void> createChatRoomInFirebase({chatData}) async {
    try {
      await chats.doc(chatData['chatRoomId']).set(chatData);
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  Future<void> sendChat(
      {required String chatRoomId,
      required Map<String, dynamic> message}) async {
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

  Future<void> updateFavorite(
      {required bool isLiked, required String productId}) async {
    try {
      final updateData = isLiked
          ? {
              'favorites': FieldValue.arrayUnion([user!.uid])
            }
          : {
              'favorites': FieldValue.arrayRemove([user!.uid])
            };
      await listings.doc(productId).update(updateData);
      final message = isLiked ? 'Added to favorites' : 'Removed from favorites';
      final color = isLiked ? blueColor : redColor;
      showSnackBar(content: message, color: color);
      // if (!isLiked) {
      //   await listings.doc(productId).update({
      //     'favorites': FieldValue.arrayRemove([user!.uid])
      //   }).then((value) {
      //     showSnackBar(
      //       content: 'Removed from favorites',
      //       color: redColor,
      //     );
      //   });
      //   return;
      // }
      // await listings.doc(productId).update({
      //   'favorites': FieldValue.arrayUnion([user!.uid])
      // }).then((value) {
      //   showSnackBar(
      //     content: 'Added to favorites',
      //     color: blueColor,
      //   );
      // });
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  // followUser({currentUserId, userId, isFollowed}) async {
  //   try {
  //     if (!isFollowed) {
  //       await users.doc(userId).update({
  //         'followers': FieldValue.arrayRemove([currentUserId])
  //       });
  //       await users.doc(currentUserId).update({
  //         'following': FieldValue.arrayRemove([userId])
  //       });
  //       return;
  //     }
  //     await users.doc(userId).update({
  //       'followers': FieldValue.arrayUnion([currentUserId])
  //     });
  //     await users.doc(currentUserId).update({
  //       'following': FieldValue.arrayUnion([userId])
  //     });
  //   } on FirebaseException {
  //     showSnackBar(
  //       content: 'Something has gone wrong. Please try again',
  //       color: redColor,
  //     );
  //   }
  // }

  Future<void> markAsSold({productId}) async {
    try {
      await listings.doc(productId).update({
        'isActive': false,
        'isSold': true,
      });
      showSnackBar(
        content: 'The product has been marked as sold',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  Future<void> promoteListingToTop({listingId}) async {
    try {
      await listings.doc(listingId).update({
        'postedAt': DateTime.now().millisecondsSinceEpoch,
      });
      showSnackBar(
        content: 'Listing succesfully boosted to top',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  Future<void> deleteChat({chatRoomId}) async {
    try {
      await chats.doc(chatRoomId).delete();
      showSnackBar(
        content: 'Chat deleted successfully',
        color: redColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  // deleteListingImage({
  //   listingId,
  //   required String imageUrl,
  // }) async {
  //   final cloudinary = Cloudinary.signedConfig(
  //     apiKey: CloudinaryServices.apiKey,
  //     apiSecret: CloudinaryServices.apiSecret,
  //     cloudName: CloudinaryServices.cloudName,
  //   );
  //   try {
  //     await cloudinary.destroy('', url: imageUrl);
  //   } catch (e) {
  //     showSnackBar(
  //       content: 'Something has gone wrong. Please try again',
  //       color: redColor,
  //     );
  //   }
  // }

  Future<void> deleteListing({listingId}) async {
    List<String> images = [];
    List<dynamic> chatsToDelete = [];
    try {
      await listings.doc(listingId.toString()).get().then((value) {
        for (int i = 0; i < value['images'].length; i++) {
          images.add(value['images'][i].toString());
        }
      });
      // for (var link in images) {
      //   await deleteListingImage(
      //     listingId: listingId,
      //     imageUrl: link,
      //   );
      // }
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
      await listings.doc(listingId.toString()).delete();
      showSnackBar(
        content: 'Product has been deleted',
        color: redColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  Future<void> submitFeedback({
    required String text,
  }) async {
    try {
      final id = uuid.v4();
      await reports.doc(id).set({
        'type': 'feedback',
        'userId': user!.uid,
        'text': text,
        'postedAt': DateTime.now().toLocal().toString(),
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

  Future<void> reportAProblem({
    required String text,
    screenshot,
  }) async {
    final id = uuid.v4();
    try {
      final cloudinary = Cloudinary.signedConfig(
        apiKey: CloudinaryServices.apiKey,
        apiSecret: CloudinaryServices.apiSecret,
        cloudName: CloudinaryServices.cloudName,
      );
      final response = await cloudinary.upload(
        file: screenshot.path,
        fileBytes: screenshot.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        folder: 'reportImages/${user!.uid}',
        fileName: id,
      );
      final String? downloadUrl = response.secureUrl;
      // final Reference storageReference =
      //     FirebaseStorage.instance.ref().child('reportImages/${user!.uid}/$id');
      // final UploadTask uploadTask = storageReference.putFile(screenshot);
      // final String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      await reports.doc(id).set({
        'type': 'screenshotReport',
        'userId': user!.uid,
        'text': text,
        'screenshot': downloadUrl,
        'postedAt': DateTime.now().toLocal().toString(),
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

  Future<void> reportItem(
      {required String listingId, required String message}) async {
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

  Future<void> reportUser(
      {required String userId, required String message}) async {
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

  Future<void> rateUser({required int stars, required String userId}) async {
    try {
      await users.doc(userId).update({
        'rating': FieldValue.increment(stars),
        'ratedBy': FieldValue.arrayUnion([user!.uid]),
      });
      Get.back();
      showSnackBar(
        content: 'You have rated this user with $stars stars',
        color: blueColor,
      );
    } on FirebaseException {
      showSnackBar(
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  // Future<void> addFields() async {
  //   try {
  //     var querySnapshots = await users.get();
  //     for (var doc in querySnapshots.docs) {
  //       await doc.reference.update({
  //         'rating': 0,
  //         'ratedBy': {''},
  //       });
  //     }
  //     showSnackBar(
  //       content: 'updated',
  //       color: blueColor,
  //     );
  //   } on FirebaseException {
  //     showSnackBar(
  //       content: 'Something has gone wrong. Please try again',
  //       color: redColor,
  //     );
  //   }
  // }

  Future<File> compressImage(File file) async {
    // Define quality constants
    const int lowQuality = 15;
    const int mediumQuality = 40;
    const int highQuality = 65;

    // Determine the quality based on the file size
    int fileSize = file.lengthSync();
    int quality = fileSize <= 500000
        ? highQuality
        : fileSize > 500000 && fileSize <= 1500000
            ? mediumQuality
            : lowQuality;

    // Compress the image using FlutterNativeImage
    var result =
        await FlutterNativeImage.compressImage(file.path, quality: quality);

    // Return the compressed file
    return result;
  }

  // Future<String> createDynamicLink() async {
  //   final dynamicLinkParams = DynamicLinkParameters(
  //     link: Uri.parse("https://www.bechdeapp.com/home"),
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
