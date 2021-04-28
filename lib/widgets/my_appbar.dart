import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/map_screen.dart';

class MySliverAppBar extends StatefulWidget {
  @override
  _MySliverAppBarState createState() => _MySliverAppBarState();
}

class _MySliverAppBarState extends State<MySliverAppBar> {
  String _address;
  bool unvisible = false;

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString('address');

    setState(() {
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);

    return SliverAppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      floating: true,
      snap: true,
      //leading: Container(),
      title: TextButton(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Tooltip(
                margin: EdgeInsets.all(20),
                message: _address == null ? "Addres Bilgileri" : _address,
                child: Column(
                  children: [
                    Text(
                      _address == null ? 'ADDRES GİRİLMEDİ ' : _address,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Lato-Regular.ttf'),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Adresinizi girmek için buraya tıklayınız ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'Lato-Regular.ttf'),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.edit_outlined, color: Colors.white),
          ],
        ),
        onPressed: () {
          locationData.getCurrentPosition().then((value) {
            if (value != null) {
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: MapScreen.id),
                screen: MapScreen(),
                withNavBar:
                    false, // 4 nav ekranından farklı yere navigate ederken false
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            } else {
              print('permission not allowed');
            }
          });
        },
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize:
            unvisible == false ? Size.fromHeight(0) : Size.fromHeight(56),
        child: Visibility(
          //will be open later on
          visible: unvisible,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Arama',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
