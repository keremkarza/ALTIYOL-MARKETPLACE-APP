import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/providers/auth_provider.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:multivendor_app/screens/navbars/my_orders_screen.dart';
import 'package:multivendor_app/screens/starter/map_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/welcome_screen.dart';

import '../profile_update_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    var locationData = Provider.of<LocationProvider>(context);
    User user = FirebaseAuth.instance.currentUser;
    userDetails.getUserDetails();
    // print("1" + userDetails.snapshot.data()['firstName']);
    // print("2" + userDetails.snapshot.toString());
    // print("3" + userDetails.toString());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('ALTIYOL', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('HESABIM',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Stack(
              children: [
                Container(
                  color: Colors.redAccent,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                  userDetails.snapshot == null
                                      ? 'A'
                                      : userDetails.snapshot == null
                                          ? 'A'
                                          : userDetails.snapshot['firstName'] ==
                                                  ""
                                              ? 'A'
                                              : userDetails
                                                  .snapshot['firstName'][0],
                                  style: TextStyle(
                                      fontSize: 40, color: Colors.white)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 70,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userDetails.snapshot == null
                                        ? 'ismini guncelle'
                                        : userDetails.snapshot
                                                    .data()['firstName'] !=
                                                null
                                            ? '${userDetails.snapshot.data()['firstName']} ${userDetails.snapshot.data()['lastName']}'
                                            : 'ismini guncelle',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    userDetails.snapshot == null
                                        ? 'mailini guncelle'
                                        : userDetails.snapshot
                                                    .data()['email'] !=
                                                null
                                            ? userDetails.snapshot
                                                .data()['email']
                                            : 'mailini guncelle',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    user.phoneNumber != null
                                        ? user.phoneNumber
                                        : "aktif degil",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              userDetails.snapshot != null
                                  ? userDetails.snapshot.data()['address']
                                  : '',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Lato-Regular.ttf'),
                              maxLines: 2,
                            ),
                            leading: Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                            ),
                            trailing: OutlinedButton(
                              onPressed: () {
                                EasyLoading.show(status: 'Lutfen Bekleyin...');
                                locationData.getCurrentPosition().then((value) {
                                  if (value != null) {
                                    EasyLoading.dismiss();
                                    pushNewScreenWithRouteSettings(
                                      context,
                                      settings:
                                          RouteSettings(name: MapScreen.id),
                                      screen: MapScreen(),
                                      withNavBar:
                                          false, // 4 nav ekranından farklı yere navigate ederken false
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  } else {
                                    EasyLoading.dismiss();
                                    print('permission not allowed');
                                  }
                                });
                              },
                              child: Text(
                                'Değiştir',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontFamily: 'Lato-Regular.ttf'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    right: 10,
                    top: 10,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        pushNewScreenWithRouteSettings(
                          context,
                          settings: RouteSettings(name: UpdateProfileScreen.id),
                          screen: UpdateProfileScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    )),
              ],
            ),
            Column(
              children: [
                Divider(),
                ListTile(
                  onTap: () {
                    pushNewScreenWithRouteSettings(
                      context,
                      settings: RouteSettings(name: MyOrdersScreen.id),
                      screen: MyOrdersScreen(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  leading: Icon(Icons.history),
                  title: Text(
                    'SİPARİŞLERİM',
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ),
                  horizontalTitleGap: 2,
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    showMyDialog();
                  },
                  leading: Icon(Icons.comment_outlined),
                  title: Text(
                    'DEĞERLENDİRMELERİM',
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ),
                  //shape: Border(bottom: BorderSide(color: Colors.grey)),
                  horizontalTitleGap: 2,
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    showMyDialog();
                  },
                  leading: Icon(Icons.notifications_none),
                  title: Text(
                    'BİLDİRİMLERİM',
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ),
                  horizontalTitleGap: 2,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.power_settings_new),
                  title: Text(
                    'ÇIKIŞ YAP',
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ),
                  horizontalTitleGap: 2,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text(
                              'ÇIKIŞ YAP',
                              style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                            ),
                            content: Text('Çıkmak istediğine emin misin ? '),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('Evet'),
                                onPressed: () {
                                  EasyLoading.show(
                                      status: 'Şuan cıkısınız yapılıyor...');
                                  FirebaseAuth.instance.signOut();
                                  EasyLoading.dismiss();
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings:
                                        RouteSettings(name: WelcomeScreen.id),
                                    screen: WelcomeScreen(),
                                    withNavBar:
                                        false, // 4 nav ekranından farklı yere navigate ederken false
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('Hayır'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
                Divider(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showMyDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Henüz Yayınlanmadı'),
            content: Text(
                'Bu özellik şuanda yayına alınmadı ve geliştirilmeye devam ediyor.'),
            actions: [
              CupertinoDialogAction(
                child: Text('TAMAM'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
