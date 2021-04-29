import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/location_provider.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/map_screen.dart';

class LandingScreen extends StatefulWidget {
  static const String id = 'landing-screen';
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider _locationProvider = LocationProvider();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'images/city.png',
                    color: Colors.grey,
                  )),
            ),
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Teslimat bölgesi seçilmedi',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato-Regular.ttf'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Sana en yakın esnafları bulmak için adresini belirt.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            _loading
                ? CircularProgressIndicator()
                : TextButton(
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                      });
                      await _locationProvider.getCurrentPosition();
                      if (_locationProvider.permissionAllowed == true) {
                        Navigator.pushReplacementNamed(context, MapScreen.id);
                      } else {
                        Future.delayed(Duration(seconds: 4), () {
                          if (_locationProvider.permissionAllowed == false) {
                            print('Permission not allowed');
                            setState(() {
                              _loading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Sana yakın esnafları bulmak için izin ver.')));
                          }
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Adresini Belirle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
// User user = FirebaseAuth.instance.currentUser;
// String _location;
// String _address;
// @override
// void initState() {
//   UserServices _userServices = UserServices();
//   _userServices.getUserById(user.uid).then((result) async {
//     if (result != null) {
//       if (result.data()['latitude'] != null) {
//         getPrefs(result);
//       } else {
//         _locationProvider.getCurrentPosition();
//         if (_locationProvider.permissionAllowed == true) {
//           Navigator.pushNamed(context, MapScreen.id);
//         } else {
//           print('Permission Not Allowed');
//         }
//       }
//     }
//   });
//   super.initState();
// }
// getPrefs(dbResult) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String location = prefs.getString('location');
//   if (location == null) {
//     print('location null ');
//     prefs.setString('address', dbResult.data()['address']);
//     prefs.setString('location', dbResult.data()['location']);
//     if (mounted) {
//       print('mounted');
//       setState(() {
//         _location = dbResult.data()['location'];
//         _address = dbResult.data()['address'];
//         _loading = false;
//       });
//     }
//     Navigator.pushReplacementNamed(context, HomeScreen.id);
//   }
//   Navigator.pushReplacementNamed(context, HomeScreen.id);
// }
