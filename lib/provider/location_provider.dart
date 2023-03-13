import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  LocationData? _locationData;

  LocationData? get locationData => _locationData;

  void updateLocation(LocationData location) async {
    _locationData = location;
    notifyListeners();
  }
}
