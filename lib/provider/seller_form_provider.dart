import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/cloudinary_services.dart';
import '/services/firebase_services.dart';

class SellerFormProvider with ChangeNotifier {
  final FirebaseServices services = FirebaseServices();
  int imagesCount = 0;
  final List<File> imagePaths = [];
  Map<String, dynamic> dataToFirestore = {};
  Map<String, dynamic> updatedDataToFirestore = {};
  final uuid = const Uuid();

  Future<String?> uploadFile(File image) async {
    final cloudinary = Cloudinary.signedConfig(
      apiKey: CloudinaryServices.apiKey,
      apiSecret: CloudinaryServices.apiSecret,
      cloudName: CloudinaryServices.cloudName,
    );
    final response = await cloudinary.upload(
      file: image.path,
      fileBytes: image.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
      folder: 'productImages/${services.user!.uid}',
      fileName: uuid.v1(),
    );
    if (response.isSuccessful) {
      return response.secureUrl;
    } else {
      return '';
    }
    // final Reference storageReference = FirebaseStorage.instance
    //     .ref()
    //     .child('productImages/${services.user!.uid}/${uuid.v1()}');
    // final UploadTask uploadTask = storageReference.putFile(image);
    // await uploadTask;
    // return await storageReference.getDownloadURL();
  }

  Future<List<String?>> uploadFiles(List<File> images) async {
    final imageUrls =
        await Future.wait(images.map((image) => uploadFile(image)));
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
