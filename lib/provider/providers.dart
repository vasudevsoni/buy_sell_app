import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:uuid/uuid.dart';

import '../services/cloudinary_services.dart';
import '/services/firebase_services.dart';

class AppNavigationProvider with ChangeNotifier {
  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;

  void switchToPage(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
}

class LocationProvider with ChangeNotifier {
  LocationData? _locationData;

  LocationData? get locationData => _locationData;

  void updateLocation(LocationData location) async {
    _locationData = location;
    notifyListeners();
  }
}

class SellerFormProvider with ChangeNotifier {
  final FirebaseServices services = FirebaseServices();

  final List<File> imagePaths = [];
  int imagesCount = 0;
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
    imagesCount++;
    notifyListeners();
  }

  removeImageFromPaths(int index) {
    imagePaths.removeAt(index);
    imagesCount--;
    notifyListeners();
  }

  getUserDetails() async {
    final value = await services.getCurrentUserData();
    notifyListeners();
    return value;
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
