import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multivendor_app/providers/auth_provider.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:multivendor_app/screens/navbars/main_screen.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map-screen';
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentLocation = LatLng(37.421632, 122.084664);
  GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  User user;
  var addressController = TextEditingController();
  @override
  void initState() {
    // check user logged in or not, while opening map screen
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
    if (user != null) {
      setState(() {
        _loggedIn = true;
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);
    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 0.0,
              child: Container(
                height: 300,
                color: Colors.white,
              ),
            ),
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: currentLocation, zoom: 14.4746),
              zoomControlsEnabled: false,
              minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.8),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              mapToolbarEnabled: true,
              onCameraMove: (CameraPosition position) {
                setState(() {
                  _locating = true;
                });
                locationData.onCameraMove(position);
              },
              onMapCreated: onCreated,
              onCameraIdle: () {
                setState(() {
                  _locating = false;
                });
                locationData.getMoveCamera();
              },
            ),
            Center(
              child: Container(
                height: 50,
                width: 50,
                margin: EdgeInsets.only(bottom: 40),
                child: Image.asset(
                  'images/marker.png',
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: SpinKitPulse(
                color: Colors.black54,
                size: 100.0,
              ),
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                height: 200,
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _locating
                          ? LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                              backgroundColor: Colors.transparent,
                            )
                          : Container(),
                      TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.location_searching,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Flexible(
                            child: Text(
                              _locating
                                  ? 'Locating...'
                                  : locationData.selectedAddress == null
                                      ? 'Locating ...'
                                      : locationData
                                          .selectedAddress.featureName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: 'Lato-Regular.ttf'),
                            ),
                          )),
                      Text(
                        _locating
                            ? ''
                            : locationData.selectedAddress == null
                                ? ''
                                : locationData.selectedAddress.addressLine,
                        style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Lato-Regular.ttf'),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: AbsorbPointer(
                          absorbing: _locating ? true : false,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                addressController.text = _locating
                                    ? ''
                                    : locationData.selectedAddress == null
                                        ? ''
                                        : locationData
                                            .selectedAddress.addressLine;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextField(
                                                style: TextStyle(
                                                    fontFamily:
                                                        'Lato-Regular.ttf'),
                                                controller: addressController,
                                                maxLines: 6,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Please enter your exact address',
                                                  labelStyle: TextStyle(
                                                      fontFamily:
                                                          'Lato-Regular.ttf'),
                                                  hintStyle: TextStyle(
                                                      fontFamily:
                                                          'Lato-Regular.ttf'),
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.green,
                                              child: TextButton(
                                                child: Text(
                                                  'CONFIRM LOCATION',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  //save address in Shared Preferences
                                                  locationData.savePrefs(
                                                      addressController.text);
                                                  if (_loggedIn == false) {
                                                    Navigator.pushNamed(context,
                                                        LoginScreen.id);
                                                  } else {
                                                    setState(() {
                                                      _auth.latitude =
                                                          locationData.latitude;
                                                      _auth.longitude =
                                                          locationData
                                                              .longitude;
                                                      _auth.address =
                                                          addressController
                                                              .text;
                                                      _auth.location =
                                                          locationData
                                                              .selectedAddress
                                                              .featureName;
                                                    });
                                                    _auth
                                                        .updateUser(
                                                      id: user.uid,
                                                      number: user.phoneNumber,
                                                    )
                                                        .then((value) {
                                                      if (value == true) {
                                                        Navigator.pushNamed(
                                                            context,
                                                            MainScreen.id);
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              'CONFIRM LOCATION',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: _locating
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
