import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multivendor_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/main_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/landing_screen.dart';

import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    print('$user : user');
    Timer(Duration(seconds: 3), () {
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user == null) {
          print('user null');
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        } else {
          print('user null degil');
          //eğer kullanıcının verisi veritabanında varsa adresini girmişmi kontrolü
          getUserData();
        }
      });
    });
    super.initState();
  }

  getUserData() async {
    UserServices _userServices = UserServices();
    _userServices.getUserById(user.uid).then((result) {
      print(result.data());
      if (result.data() == null) {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
      // lokasyon verisi var mı kontrolü
      if (result.data()['address'] != null) {
        updatePrefs(result);
      }
      Navigator.pushReplacementNamed(context, LandingScreen.id);
    });
  }

  Future<void> updatePrefs(result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', result['latitude']);
    prefs.setDouble('longitude', result['longitude']);
    prefs.setString('address', result['address']);
    prefs.setString('location', result['location']);

    Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Hero(
                  child:
                      Image.asset("images/ALTIYOL_LOGO_RENK_TRANSPARENT.png"),
                  tag: 'logo',
                ),
                // Positioned(
                //   top: 120,
                //   left: 120,
                //   child: SpinKitCircle(
                //     color: Colors.white,
                //     size: 120.0,
                //   ),
                // ),
              ],
            ),
            Column(
              children: [
                Text(
                  "ALTIYOL",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 25,
                  ),
                ),
                SpinKitWave(
                  color: Colors.black87,
                  size: 50.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
