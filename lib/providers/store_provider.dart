import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multivendor_app/services/store_services.dart';
import 'package:multivendor_app/services/user_services.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/welcome_screen.dart';

class StoreProvider with ChangeNotifier {
  StoreServices _storeServices = StoreServices();
  UserServices _userServices = UserServices();
  User user = FirebaseAuth.instance.currentUser;
  var userLatitude = 0.0;
  var userLongitude = 0.0;
  DocumentSnapshot storeDetails;
  String distance;
  String selectedProductCategory;
  String selectedSubProductCategory;
  String status;
  String selectedSuperCategory;

  filterOrder(status, isBuild) {
    //filterOrder name is because i copied from there :)
    // bu kısım supercategory için
    //SchedulerBinding.instance.addPostFrameCallback((_) {
    this.status = status;
    notifyListeners();
    print(status);
    // if (isBuild) {
    //   print('build-filterOrder');
    // } else {
    //   print('build dışı-filterOrder');
    //   notifyListeners();
    // }
    //});
  }

  updateSuperCat(selected) {
    this.selectedSuperCategory = selected;
    notifyListeners();
  }

  getSelectedStore(storeDetails, distance) {
    print('getStore');
    this.storeDetails = storeDetails;
    this.distance = distance;
    notifyListeners();
  }

  getSelectedCategory(category) {
    print('getCat');
    this.selectedProductCategory = category;
    notifyListeners();
  }

  getSelectedSubCategory(subCategory) {
    print('getSubcat');
    this.selectedSubProductCategory = subCategory;
    notifyListeners();
  }

  String getDistance(location) {
    var distance = Geolocator.distanceBetween(
      //yes this error is about this, but my main problem is infinite loop
      //show me that
      userLatitude,
      userLongitude,
      41.0097531,
      29.0962564,
    );
    var distanceInKm = distance / 1000;
    return distanceInKm.toStringAsFixed(2);
  }

  Future<void> getUserLocationData(context) async {
    _userServices.getUserById(user.uid).then((result) {
      if (user != null) {
        this.userLatitude = result.data()['latitude'];
        this.userLongitude = result.data()['longitude'];
        notifyListeners();
        print('getUserData');
      } else {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
