import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/services/user_services.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/main_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/landing_screen.dart';

import 'location_provider.dart';

class AuthProvider with ChangeNotifier {
  String smsOtp;
  String verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String error = "";
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  String screen;
  double latitude;
  double longitude;
  String address;
  String location;
  DocumentSnapshot snapshot;

  Future<void> verifyPhone({BuildContext context, String number}) async {
    this.loading = true;
    notifyListeners();
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      print('comp önce');
      //await _auth.signInWithCredential(credential);
      print('comp sonra');
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = false;
      print('fail önce');
      print(e.code);
      print('fail sonra');
      this.error = e.toString();
      notifyListeners();
    };
    final PhoneCodeSent smsOtpSend = (String verId, int resendToken) async {
      this.verificationId = verId;

      // open dialog to enter received OTP SMS
      print('sent önce');
      smsOtpDialog(context, number);
      print('sent sonra');
    };
    try {
      print('verify önce');
      _auth.verifyPhoneNumber(
        timeout: Duration(seconds: 120),
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
      print('verify sonra');
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
      print('verify 2.sonra');
    }
  }

  Future<bool> smsOtpDialog(BuildContext context, String number) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Teyit Kodu'),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'SMS olarak gelen 6 haneli OTP kodunuzu giriniz',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);
                    final User user =
                        (await _auth.signInWithCredential(phoneAuthCredential))
                            .user;

                    if (user != null) {
                      this.loading = false;
                      notifyListeners();

                      _userServices.getUserById(user.uid).then((snapShot) {
                        if (snapShot.exists) {
                          //user data already exists
                          if (this.screen == 'Login') {
                            //need to check if user data already exists in db or not
                            //if its login, no new data, so no need to update
                            if (snapShot.data()['address'] != null) {
                              Navigator.pushReplacementNamed(
                                  context, MainScreen.id);
                            }
                            Navigator.pushReplacementNamed(
                                context, LandingScreen.id);
                          } else {
                            //need to update new selected address
                            updateUser(id: user.uid, number: user.phoneNumber);
                            Navigator.pushReplacementNamed(
                                context, MainScreen.id);
                          }
                        } else {
                          //user data does not exist
                          //will create new data in db
                          _createUser(id: user.uid, number: user.phoneNumber);
                          Navigator.pushReplacementNamed(
                              context, LandingScreen.id);
                        }
                      });
                    } else {
                      print('Login Failed');
                    }
                  } catch (e) {
                    this.error = 'Gecersiz OTP';
                    notifyListeners();
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'TAMAM',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        }).whenComplete(() {
      this.loading = false;
      notifyListeners();
    });
  }

  void _createUser({
    String id,
    String number,
  }) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
      'location': this.location,
      'email': '',
      'firstName': '',
      'lastName': '',
    });
    this.loading = false;
    notifyListeners();
  }

  // this method can be void without returning any value
  Future<bool> updateUser({String id, String number}) async {
    try {
      _userServices.updateUserData({
        'id': id,
        'number': number,
        'latitude': this.latitude,
        'longitude': this.longitude,
        'address': this.address,
        'location': this.location,
        'email': '',
        'firstName': '',
        'lastName': '',
      });
      this.loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error $e');
      return false;
    }
  }

  getUserDetails() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get();
    if (result != null) {
      this.snapshot = result;
      notifyListeners();
    } else {
      this.snapshot = null;
      notifyListeners();
    }

    return result;
  }
}
