import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  LocationData? locationData;

  updateLocation(location) async {
    locationData = location;
    notifyListeners();
  }
}
