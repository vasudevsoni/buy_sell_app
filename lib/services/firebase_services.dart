import 'package:buy_sell_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseServices {
  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  CollectionReference listings =
      FirebaseFirestore.instance.collection('listings');

  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');

  Future<DocumentSnapshot> getCurrentUserData() async {
    DocumentSnapshot doc = await users.doc(user!.uid).get();
    return doc;
  }

  Future<DocumentSnapshot> getUserData(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<DocumentSnapshot> getProductDetails(String id) async {
    DocumentSnapshot doc = await listings.doc(id).get();
    return doc;
  }

  updateUserDetails(id, Map<String, dynamic> data) async {
    await users.doc(id).update(data);
  }

  createChatRoomInFirebase({chatData, context}) async {
    await chats.doc(chatData['chatRoomId']).set(chatData).catchError((e) {
      showSnackBar(
        context: context,
        content: 'Something has gone wrong. Plase try again later.',
        color: redColor,
      );
    });
  }

  sendChat({chatRoomId, message, context}) async {
    await chats
        .doc(chatRoomId)
        .collection('messages')
        .add(message)
        .catchError((e) {
      showSnackBar(
        context: context,
        content: 'Unable to send message. Plase try again later.',
        color: redColor,
      );
    });
    await chats.doc(chatRoomId).update({
      'lastChat': message['message'],
      'lastChatTime': message['time'],
      'read': false,
    });
  }

  updateFavorite({isLiked, productId, context}) {
    if (isLiked) {
      listings.doc(productId).update({
        'favorites': FieldValue.arrayUnion([user!.uid])
      });
      showSnackBar(
        context: context,
        content: 'Added to favorites',
        color: blueColor,
      );
    } else {
      listings.doc(productId).update({
        'favorites': FieldValue.arrayRemove([user!.uid])
      });
      showSnackBar(
        context: context,
        content: 'Removed from favorites',
        color: redColor,
      );
    }
  }

  deleteChat({chatRoomId, context}) async {
    await chats.doc(chatRoomId).delete().then((value) {
      showSnackBar(
        context: context,
        content: 'Chat deleted successfully',
        color: redColor,
      );
    });
  }

  deleteListingImage({listingId, required String imageUrl, context}) async {
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    try {
      await storageRef.delete();
    } on FirebaseException catch (_) {
      showSnackBar(
        context: context,
        content: 'Something has gone wrong. Please try again',
        color: redColor,
      );
    }
  }

  deleteListing({listingId, context}) async {
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
          context: context,
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
        await deleteChat(chatRoomId: chatRoomId.toString(), context: context);
      }
      await listings.doc(listingId.toString()).delete().then((value) {
        showSnackBar(
          context: context,
          content: 'Listing deleted',
          color: redColor,
        );
      });
    } on FirebaseAuthException catch (_) {
      showSnackBar(
        context: context,
        content: 'Unable to delete item. Please try again',
        color: redColor,
      );
    }
  }

  // reportItem({listingId, message, context}) async {
  //   var id = DateTime.now().millisecondsSinceEpoch;
  //   await reports.doc().add({
  //     'productId': listingId,
  //     'userUid': user!.uid,
  //     'reportId': id,
  //     'message': message,
  //   }).then((value) {
  //     showSnackBar(
  //       context: context,
  //       content:
  //           'Report filed successfully. We will get back to you as soon as possible.',
  //       color: blueColor,
  //     );
  //   }).catchError((_) {
  //     showSnackBar(
  //       context: context,
  //       content: 'Something has gone wrong. Please try again.',
  //       color: blueColor,
  //     );
  //   });
  // }
}
