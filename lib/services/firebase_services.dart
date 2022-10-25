import 'package:buy_sell_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  CollectionReference listings =
      FirebaseFirestore.instance.collection('listings');

  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

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
        content: 'Unable to chat with seller. Plase try again later.',
        color: redColor,
      );
    });
  }

  createChat({chatRoomId, message, context}) async {
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

  deleteChat(chatRoomId) async {
    await chats.doc(chatRoomId).delete();
  }

  updateFavorite({isLiked, productId, context}) async {
    if (isLiked) {
      await listings.doc(productId).update({
        'favorites': FieldValue.arrayUnion([user!.uid])
      });
      showSnackBar(
        context: context,
        content: 'Added to your favorites',
        color: blueColor,
      );
    } else {
      await listings.doc(productId).update({
        'favorites': FieldValue.arrayRemove([user!.uid])
      });
      showSnackBar(
        context: context,
        content: 'Removed from your favorites',
        color: redColor,
      );
    }
  }
}
