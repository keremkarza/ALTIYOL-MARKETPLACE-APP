import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/auth_provider.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _validPhoneNumber = false;
  var _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: auth.error == 'Invalid OTP' ? true : false,
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          "${auth.error} Try again",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
                Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Enter Your phone number to proceed",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixText: '+90',
                    labelText: '10 digit mobile number',
                  ),
                  autofocus: true,
                  maxLength: 10,
                  controller: _phoneNumberController,
                  onTap: () {
                    setState(() {});
                  },
                  onChanged: (value) {
                    print(value.length);
                    print(_phoneNumberController.text);
                    if (value.length == 10) {
                      setState(() {
                        _validPhoneNumber = true;
                      });
                    } else {
                      setState(() {
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
                            //print(locationData.longitude);
                            setState(() {
                              auth.loading = true;
                              auth.screen = 'MapScreen';
                              auth.latitude = locationData.latitude;
                              auth.longitude = locationData.longitude;
                              auth.address =
                                  locationData.selectedAddress.addressLine;
                            });
                            String number = '+90${_phoneNumberController.text}';
                            auth
                                .verifyPhone(
                              context: context,
                              number: number,
                            )
                                .then((value) {
                              _phoneNumberController.clear();
                              setState(() {
                                auth.loading =
                                    false; // to disable circle indicator
                              });
                            });
                          },
                          child: auth.loading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  _validPhoneNumber
                                      ? 'CONTINUE '
                                      : 'ENTER PHONE NUMBER',
                                  style: TextStyle(
                                    color: Colors.white,
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
        ),
      ),
    );
  }
}
