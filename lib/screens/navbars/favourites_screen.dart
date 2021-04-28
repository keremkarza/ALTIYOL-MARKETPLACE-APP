import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/screens/products/product_details_screen.dart';
import 'package:multivendor_app/services/favorites_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class FavouritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FavouritesServices _services = FavouritesServices();
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites Screen'),
      ),
      body: Container(
        child: Column(
          children: [
            Center(
              child: Container(
                child: Center(child: Text('Your Favourite Products')),
                height: 50,
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _services.getFavouritesItems(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text('There is no favourite product you choose.'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  return Expanded(
                    child: new ListView(
                      children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        if (document.data()['product'] == null) {
                          return Center(
                            child: Text(
                                'There is no favourite product you choose.'),
                          );
                        }
                        return Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 0.1)),
                          child: new ListTile(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(
                                    name: ProductDetailsScreen.id),
                                screen: ProductDetailsScreen(
                                  document: document,
                                  isFromNavBar: true,
                                ),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.network(document
                                      .data()['product']['productImage']),
                                ),
                              ),
                            ),
                            trailing: FittedBox(
                              child: Row(
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${document.data()['product']['price'].toString()} TL',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          document
                                              .data()['product']['weight']
                                              .toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          document
                                              .data()['product']['sku']
                                              .toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outlined,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _services.favourites
                                          .doc(document.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            subtitle: new Text(document.data()['product']
                                ['seller']['shopName']),
                            title: new Text(
                                document.data()['product']['productName']),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveForLater(document) {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;
    return _favourite.add({
      'product': document.data(),
      'customerId': user.uid,
    });
  }
}
