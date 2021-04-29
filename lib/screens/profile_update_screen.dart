import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/services/user_services.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String id = 'update-profile-screen';
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  User user = FirebaseAuth.instance.currentUser;
  UserServices _userServices = UserServices();

  @override
  void initState() {
    _userServices.getUserById(user.uid).then((value) {
      if (mounted) {
        setState(() {
          firstNameController.text = value.data()['firstName'];
          lastNameController.text = value.data()['lastName'];
          emailController.text = value.data()['email'];
          mobileController.text = user.phoneNumber;
        });
      }
    });
    super.initState();
  }

  updateProfile() {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profili Güncelle',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Lato-Regular.ttf',
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomSheet: InkWell(
        onTap: () {
          if (_formKey.currentState.validate()) {
            EasyLoading.show(status: 'Profil Guncelleniyor...');
            updateProfile().then((value) {
              EasyLoading.showSuccess('Profil Guncellendi');
              Navigator.pop(context);
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          color: Theme.of(context).backgroundColor,
          child: Center(
            child: Text(
              'Güncelle',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Lato-Regular.ttf',
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Ad',
                      labelStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Adınızı Girin';
                      }
                      return null;
                    },
                  )),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        labelText: 'Soyad',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Soyadınızı Girin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                controller: mobileController,
                enabled: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  labelText: 'Telefon',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email adresinizi girin';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
