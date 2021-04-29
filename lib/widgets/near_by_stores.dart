import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multivendor_app/constants.dart';
import 'package:multivendor_app/providers/cart_provider.dart';
import 'package:multivendor_app/providers/store_provider.dart';
import 'package:multivendor_app/screens/vendor_home_screen.dart';
import 'package:multivendor_app/services/store_services.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class NearByStores extends StatefulWidget {
  final String statusFromHome;

  NearByStores({this.statusFromHome});

  @override
  _NearByStoresState createState() => _NearByStoresState();
}

class _NearByStoresState extends State<NearByStores> {
  List shopDistance = [];
  String superCategoryStatus;

  int tag = 0;
  List<String> options = [
    'Tümü',
    'Yemek',
    'Market',
    'Giyim',
    'Kasap',
    'Eczane',
    'Diger',
  ];
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
  //
  // String getDistance(location) {
  //   var distance = Geolocator.distanceBetween(
  //       latitude, longitude, location.latitude, location.longitude);
  //   var distanceInKm = distance / 1000;
  //   return distanceInKm.toStringAsFixed(2);
  // }
  // version 1 --current location near stores------

  //CartServices _cartServices = CartServices();
  StoreServices _storeServices = StoreServices();
  PaginateRefreshedChangeListener _paginateRefreshedChangeListener =
      PaginateRefreshedChangeListener();

  // @override
  // void didChangeDependencies() {
  //   final _store = Provider.of<StoreProvider>(context, listen: false);
  //   setState(() {
  //     print('changebefore normal sup : $superCategoryStatus');
  //     print('change provider sup : ${_store.status}');
  //
  //     _store.filterOrder(
  //         superCategoryStatus == null ? options[tag] : superCategoryStatus,
  //         true);
  //     superCategoryStatus = _store.status;
  //     print('changeafter normal sup : $superCategoryStatus');
  //   });
  //   super.didChangeDependencies();
  // }
  //
  // @override
  // void didUpdateWidget(covariant NearByStores oldWidget) {
  //   final _storeProvider = Provider.of<StoreProvider>(context, listen: false);
  //   setState(() {
  //     print('update normal sup : $superCategoryStatus');
  //     print('update provider sup : ${_storeProvider.status}');
  //     superCategoryStatus = _storeProvider.status;
  //   });
  //   super.didUpdateWidget(oldWidget);
  // }
  //

  @override
  void didChangeDependencies() {
    // final _cart = Provider.of<CartProvider>(context);
    // shopDistance.isEmpty
    //     ? print('emptychange')
    //     : _cart.getDistance(shopDistance[0]);

    // if (_cartServices.didChangeTime) {
    //   _cartServices.didChangeTime = false;
    //   print(_cartServices.didChangeTime);
    //_filterInStart();
    // }
    _filterInStart();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _filterInStart(); //u mean this?
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var query = tag > 0 ? superCategoryStatus : null;
    final _cartProvider = Provider.of<CartProvider>(context);
    final _storeProvider = Provider.of<StoreProvider>(context);
    print('nearby build yenilendi. streambuilder');
    //if its streambuilder, it will keep on make any new update. or else untill u restart the app, u wont able to see the update. so its up tp u, u can use any way
    //superCategoryStatus = _storeProvider.status;
    //print('superCat : $superCategoryStatus'); // for tracking

    //use just provider and bring selected vlue from provider to here
    return Container(
      //where('superCategory', isEqualTo: query)

      //     .where('superCategory',
      // isEqualTo: _storeProvider
      //     .selectedSuperCategory) //not like that. ehrere is the switch,

      child: StreamBuilder<QuerySnapshot>(
        //strambuilder is there.so?
        stream: _storeServices.vendors
            .where('accVerified', isEqualTo: true)
            .where('shopOpen', isEqualTo: true)
            .orderBy('shopName')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //print(snapshot);
          //print('degisik : ${snapshot.data.docs[0]['superCategory']}');
          //print(_storeProvider.status);
          if (snapshot.hasError) {
            return const Text(
                'Something went wrong'); // this will not rerun with build,thats good!
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }

          if (snapshot.data == null) {
            print('snapshot.data null');
            return Center(
                child: Text(tag > 0
                    ? 'No ${options[tag]} stores'
                    : 'No stores. Soon there will be.'));
          }
          if (snapshot.data.size == 0) {
            print('snapshot.data.size = 0');
            return Row(
              children: [
                // BackButton(
                //   onPressed: () {
                //     setState(() {
                //     });
                //   },
                // ),
                Center(
                    child: Text(tag > 0
                        ? 'No ${options[tag]} stores'
                        : 'No stores. Soon there will be.')),
              ],
            );
          }
          for (int i = 0; i <= snapshot.data.docs.length - 1; i++) {
            var distance = Geolocator.distanceBetween(
                _storeProvider.userLatitude,
                _storeProvider.userLongitude,
                snapshot.data.docs[i]['location'].latitude,
                snapshot.data.docs[i]['location'].longitude);
            var distanceInKm = distance / 1000;
            shopDistance.add(distanceInKm);
          }
          shopDistance
              .sort(); //en yakın dükkana göre sıralayacak, eğer en yakını 10km den fazlaysa yakın dükkan yok demektir.

          if (shopDistance[0] > 2) {
            print(shopDistance[0].toString() + ' hey');
            // buradaki 10 , yakın olarak gösterilmek için max km
            return Container(
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      ' Hepsi bu kadardı. ',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Image.asset(
                    'images/city.png',
                    color: Colors.black12,
                  ),
                  Positioned(
                      right: 10,
                      top: 80,
                      child: Container(
                        width: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'Made by :',
                            //   style: TextStyle(color: Colors.black54),
                            // ),
                            Text(
                              'ALTIYOL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Anton',
                                letterSpacing: 2,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            );
          }

          //_storeProvider.getDistance(shopDistance[0]);
          SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                _storeProvider.getUserLocationData(context);
                shopDistance.isEmpty
                    ? print('empty')
                    : _cartProvider.getDistance(shopDistance[0]);
              }));

          return Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   //here
                //   height: 56,
                //   width: MediaQuery.of(context).size.width,
                //   child: ChipsChoice<int>.single(
                //     choiceStyle:
                //         C2ChoiceStyle(borderRadius: BorderRadius.circular(3)),
                //     value: tag,
                //     onChanged: (val) {
                //       if (val == 0) {
                //         setState(() {
                //           _storeProvider.status = null;
                //         });
                //       }
                //       setState(() {
                //         //update this value with a value in provider . thats all
                //         tag = val;
                //         //actually what you did is here
                //         if (tag > 0) {
                //           _storeProvider.updateSuperCat(val);
                //           //_storeProvider.filterOrder(options[val], false);
                //         }
                //       });
                //     },
                //     choiceItems: C2Choice.listFrom<int, String>(
                //       source: options,
                //       value: (i, v) => i,
                //       label: (i, v) => v,
                //     ),
                //   ),
                // ),
                RefreshIndicator(
                    child: PaginateFirestore(
                      bottomLoader: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                      header: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 20),
                            child: Text(
                              'Yakınındakiler',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Lato-Regular.ttf'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 10),
                            child: Text(
                              'Yakındaki en iyi dükkanlarla tanış.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: 'Lato-Regular.ttf'),
                            ),
                          ),
                        ],
                      ),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilderType: PaginateBuilderType.listView,
                      itemBuilder: (index, context, document) {
                        return InkWell(
                          onTap: () {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => setState(() {}));
                            _storeProvider.getSelectedStore(
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
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Card(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          document['url'],
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        child: Text(
                                          document.data()['shopName'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                150,
                                        child: Text(
                                          document.data()['dialog'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: kStoreCardStyle,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                150,
                                        child: Text(
                                          document.data()['address'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: kStoreCardStyle,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        '${getDistance(document['location'])} Km',
                                        overflow: TextOverflow.ellipsis,
                                        style: kStoreCardStyle,
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        //burası rating  ve sonradan yapılacak
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.amber[300],
                                          ),
                                          SizedBox(width: 4),
                                          Text('3.2', style: kStoreCardStyle),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      //.where('superCategory', isEqualTo: query)
                      query: _storeServices.vendors
                          .where('accVerified', isEqualTo: true)
                          .where('shopOpen', isEqualTo: true)
                          //.where('superCategory', isEqualTo: query)
                          .orderBy('shopName'),
                      listeners: [
                        _paginateRefreshedChangeListener,
                        _storeProvider,
                      ],
                      footer: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Container(
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  ' Hepsi bu kadardı. ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Image.asset(
                                'images/city.png',
                                color: Colors.black12,
                              ),
                              Positioned(
                                  right: 10,
                                  top: 80,
                                  child: Container(
                                    width: 100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Made by :',
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                        Text(
                                          'ALTIYOL',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Anton',
                                            letterSpacing: 2,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    onRefresh: () async {
                      // WidgetsBinding.instance
                      //     .addPostFrameCallback((_) => setState(() {}));
                      _paginateRefreshedChangeListener.refreshed = true;
                      //superCategoryStatus = _storeProvider.status;
                      print('selam');
                    }),
              ],
            ),
          );
        },
      ),
    );
  }

  String getDistance(location) {
    final _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    var distance = Geolocator.distanceBetween(_storeProvider.userLatitude,
        _storeProvider.userLongitude, location.latitude, location.longitude);
    var distanceInKm = distance / 1000;
    return distanceInKm.toStringAsFixed(2);
  }

  _filterInStart() async {
    await Future.delayed(Duration(milliseconds: 50));
    final _store = Provider.of<StoreProvider>(context, listen: false);
    final _cart = Provider.of<CartProvider>(context, listen: false);
    //SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    //print('denemefilter : $superCategoryStatus');
    // _store.filterOrder(
    //     superCategoryStatus == null ? options[tag] : _store.status, true);
    _store.getUserLocationData(context);
    shopDistance.isEmpty ? print('empty') : _cart.getDistance(shopDistance[0]);
    //}));

    //do something
  }
}

//its not an issue. u can do it any way u prefer, now error is about that location.
// but infinite loop will cause performance problem ?
//no much , but u an change to futurebuilder if u want
// but then user wont see ui change, notification when add product.
