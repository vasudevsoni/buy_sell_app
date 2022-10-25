import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/firebase_services.dart';

class SellerFormProvider with ChangeNotifier {
  final FirebaseServices services = FirebaseServices();
  int imagesCount = 0;
  final List<File> imagePaths = [];
  Map<String, dynamic> dataToFirestore = {};
  Map<String, dynamic> updatedDataToFirestore = {};
  var uuid = const Uuid();

  Future<String> uploadFile(File image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('productImages/${services.user!.uid}/${uuid.v1()}');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  Future<List<String>> uploadFiles(List<File> images) async {
    var imageUrls = await Future.wait(images.map((image) => uploadFile(image)));
    return imageUrls;
  }

  clearImagesCount() {
    imagesCount = 0;
    notifyListeners();
  }

  addImageToPaths(File image) {
    imagePaths.add(image);
    notifyListeners();
  }

  getUserDetails() async {
    await services.getCurrentUserData().then((value) {
      notifyListeners();
      return value;
    });
  }

  clearDataAfterSubmitListing() {
    imagesCount = 0;
    imagePaths.clear();
    dataToFirestore.clear();
    notifyListeners();
  }

  clearDataAfterUpdateListing() {
    updatedDataToFirestore.clear();
    notifyListeners();
  }
}
