import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multivendor_app/providers/store_provider.dart';
import 'package:multivendor_app/screens/vendor_home_screen.dart';
import 'package:multivendor_app/services/store_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TopPickedStores extends StatefulWidget {
  @override
  _TopPickedStoresState createState() => _TopPickedStoresState();
}

class _TopPickedStoresState extends State<TopPickedStores> {
  // version 1 --current location near stores------
  // other one is for selected location near stores
  // double latitude = 0.0;
  // double longitude = 0.0;
  //
  // @override
  // void didChangeDependencies() {
  //   final _storeData = Provider.of<StoreProvider>(context);
  //   _storeData.determinePosition().then((position) {
  //     setState(() {
  //       latitude = position.latitude;
  //       longitude = position.longitude;
  //     });
  //   });
  //   super.didChangeDependencies();
  // }

  // String getDistance(location) {
  //   var distance = Geolocator.distanceBetween(
  //       latitude, longitude, location.latitude, location.longitude);
  //   var distanceInKm = distance / 1000;
  //   return distanceInKm.toStringAsFixed(2);
  // }

  // version 1 --only near stores-------------------------

  // @override
  // void didChangeDependencies() {
  //   //_filterInStart();
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    _filterInStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const MAX_KM_NEARBY_STORES = 10;
    StoreServices _storeServices = StoreServices();

    //for selected location near stores
    final _storeData = Provider.of<StoreProvider>(context);
    //print('toppick build');

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(_storeData.userLatitude,
          _storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeServices.getTopPickedStores(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (!snapShot.hasData) {
            print('Data yok');
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          List shopDistance = [];
          for (int i = 0; i <= snapShot.data.docs.length - 1; i++) {
            var distance = Geolocator.distanceBetween(
                _storeData.userLatitude,
                _storeData.userLongitude,
                snapShot.data.docs[i]['location'].latitude,
                snapShot.data.docs[i]['location'].longitude);
            var distanceInKm = distance / 1000;
            shopDistance.add(distanceInKm);
          }
          shopDistance
              .sort(); //en yakın dükkana göre sıralayacak, eğer en yakını 10km den fazlaysa yakın dükkan yok demektir.
          if (shopDistance[0] > 2) {
            return Container(
              height: 60,
              child: Material(
                elevation: 5,
                shadowColor: Colors.white70,
                child: Text(
                  'Şimdilik senin bulunduğun bölgede hizmette değiliz. Lütfen sonra tekrar deneyiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontFamily: 'Lato-Regular.ttf'),
                ),
              ),
            );
          }
          return Container(
            height: 140,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        height: 22,
                        child: Image.asset('images/like.gif'),
                      ),
                    ),
                    Text(
                      'Keşfet',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Lato-Regular.ttf'),
                    ),
                  ],
                ),
                Container(
                  child: Flexible(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          snapShot.data.docs.map((DocumentSnapshot document) {
                        if (double.parse(getDistance(document['location'])) <=
                            MAX_KM_NEARBY_STORES) {
                          return InkWell(
                            onTap: () {
                              _storeData.getSelectedStore(
                                  document, getDistance(document['location']));
                              pushNewScreenWithRouteSettings(
                                context,
                                settings:
                                    RouteSettings(name: VendorHomeScreen.id),
                                screen: VendorHomeScreen(),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                width: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 80,
                                        width: 80,
                                        child: Card(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              document['url'],
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        )),
                                    Container(
                                      child: Text(
                                        document['shopName'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${getDistance(document['location'])} Km',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: Colors.black54,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          //if no stores
                          return Container();
                        }
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  _filterInStart() async {
    await Future.delayed(Duration(milliseconds: 50));
    final _storeData = Provider.of<StoreProvider>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _storeData.getUserLocationData(context);
    });

    //do something
  }
}
