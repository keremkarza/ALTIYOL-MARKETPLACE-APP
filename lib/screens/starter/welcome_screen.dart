import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/auth_provider.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:provider/provider.dart';

import 'onboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    void showBottomSheet(context) {
      bool _validPhoneNumber = false;
      var _phoneNumberController = TextEditingController();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0),
            ),
          ),
          child: StatefulBuilder(builder: (context, StateSetter myState) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: auth.error == 'Gecersiz OTP' ? true : false,
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              "${auth.error} Tekrar deneyin",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "GİRİŞ YAP",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato-Regular.ttf',
                      ),
                    ),
                    Text(
                      "İlerlemek için numaranı gir",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Lato-Regular.ttf',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixText: '+90',
                        labelText: '10 haneli telefon numarası',
                      ),
                      autofocus: true,
                      maxLength: 10,
                      controller: _phoneNumberController,
                      onTap: () {
                        myState(() {});
                      },
                      onChanged: (value) {
                        print(value.length);
                        print(_phoneNumberController.text);
                        if (value.length == 10) {
                          myState(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          myState(() {
                            _validPhoneNumber = false;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: _validPhoneNumber ? false : true,
                            child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                (states) => _validPhoneNumber
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              )),
                              onPressed: () {
                                myState(() {
                                  auth.loading = true;
                                });
                                String number =
                                    '+90${_phoneNumberController.text}';
                                auth
                                    .verifyPhone(
                                  context: context,
                                  number: number,
                                )
                                    .then((value) {
                                  _phoneNumberController.clear();
                                });
                              },
                              child: auth.loading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      _validPhoneNumber
                                          ? 'DEVAM ET '
                                          : 'NUMARANI GİR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Lato-Regular.ttf',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ).whenComplete(() {
        setState(() {
          auth.loading = false;
          _phoneNumberController.clear();
        });
      });
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Visibility(
              visible: false,
              child: Positioned(
                right: 0.0,
                top: 10.0,
                child: TextButton(
                  child: Text(
                    'SKIP',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Column(
              children: [
                Expanded(child: OnBoardScreen()),
                Text(
                  'Sana en yakın dükkanlardan sipariş vermeye hazır mısın?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Lato-Regular.ttf',
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: locationData.loading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'GİRİŞ YAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'CaviarDreams.ttf',
                          ),
                        ),
                  onPressed: () async {
                    setState(() {
                      locationData.loading = true;
                    });
                    setState(() {
                      auth.screen = 'Login';
                    });
                    showBottomSheet(context);

                    // await locationData.getCurrentPosition();
                    // if (locationData.permissionAllowed == true) {
                    //   Navigator.pushReplacementNamed(context, MapScreen.id);
                    //   setState(() {
                    //     locationData.loading = false;
                    //   });
                    // } else {
                    //   print('Permission not allowed');
                    //   setState(() {
                    //     locationData.loading = false;
                    //   });
                    // }
                  },
                ),
                // TextButton(
                //   child: RichText(
                //     text: TextSpan(
                //         text: 'Zaten müşterimiz misin ? ',
                //         style: TextStyle(
                //           color: Colors.grey,
                //           fontFamily: 'Lato-Regular.ttf',
                //         ),
                //         children: [
                //           // TextSpan(
                //           //   text: ' Giriş Yap',
                //           //   style: TextStyle(
                //           //     fontWeight: FontWeight.bold,
                //           //     color: Theme.of(context).primaryColor,
                //           //     fontFamily: 'Lato-Regular.ttf',
                //           //   ),
                //           // )
                //         ]),
                //   ),
                //   onPressed: () {
                //     FirebaseCrashlytics.instance.crash();
                //     throw Exception("This is a crash!");
                //     // setState(() {
                //     //   auth.screen = 'Login';
                //     // });
                //     // showBottomSheet(context);
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// if (locationData.selectedAddress != null) {
// updateUser(
// id: user.uid,
// number: user.phoneNumber,
// latitude: locationData.latitude,
// longitude: locationData.longitude,
// address: locationData.selectedAddress.addressLine,
// );
// } else {
// // create user data in fireStore after user succesfully registered,
// _createUser(
// id: user.uid,
// number: user.phoneNumber,
// latitude: latitude,
// longitude: longitude,
// address: address,
// );
// }
// // navigate to homepage after login.
//
// if (user != null) {
// Navigator.of(context).pop();
// this.loading = false;
//
// //dont want come back to welcome screen after logged in
// Navigator.of(context).pushReplacementNamed(HomeScreen.id);
// } else {
// print('login Failed');
// }
