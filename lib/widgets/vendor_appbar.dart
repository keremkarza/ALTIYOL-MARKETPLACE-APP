import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multivendor_app/providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _store = Provider.of<StoreProvider>(context);

    mapLauncher() async {
      GeoPoint location = _store.storeDetails['location'];
      final availableMaps = await MapLauncher.installedMaps;

      await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude),
        title: '${_store.storeDetails['shopName']} is here',
      );
    }

    return SliverAppBar(
      floating: true,
      snap: true,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      expandedHeight: 230, //normal 260 tı
      flexibleSpace: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  // image: DecorationImage(
                  //   fit: BoxFit.fill,
                  //   image: NetworkImage(_store.storeDetails['url']),
                  // ),
                ),
                child: Container(
                  color: Colors.grey.withOpacity(.9),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Text(
                          _store.storeDetails['dialog'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Lato-Regular.ttf',
                          ),
                        ),
                        Text(
                          _store.storeDetails['address'],
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Lato-Regular.ttf'),
                        ),
                        Text(
                          _store.storeDetails['email'],
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Lato-Regular.ttf'),
                        ),
                        Text(
                          'Uzaklık : ${_store.distance} km',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        Visibility(
                          visible: false,
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.white),
                              Icon(Icons.star, color: Colors.white),
                              Icon(Icons.star, color: Colors.white),
                              Icon(Icons.star_half, color: Colors.white),
                              Icon(Icons.star_outline, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                ' (3.5)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  launch(
                                      'tel:${_store.storeDetails['mobile']}');
                                },
                                icon: Icon(
                                  Icons.phone,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  mapLauncher();
                                },
                                icon: Icon(
                                  Icons.map,
                                  color: Theme.of(context).primaryColor,
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
            ),
          ),
        ),
      ),
      actions: [
        Visibility(
          visible: false,
          child: IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.search),
          ),
        ),
      ],
      title: Text(
        _store.storeDetails['shopName'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
