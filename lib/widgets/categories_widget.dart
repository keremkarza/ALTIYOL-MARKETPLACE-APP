import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/store_provider.dart';
import 'package:multivendor_app/services/product_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/products/product_list_screen.dart';

class VendorCategories extends StatefulWidget {
  @override
  _VendorCategoriesState createState() => _VendorCategoriesState();
}

class _VendorCategoriesState extends State<VendorCategories> {
  ProductServices _services = ProductServices();
  List _categoryList = [];

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);

    FirebaseFirestore.instance
        .collection('products')
        .where('seller.sellerUid', isEqualTo: _store.storeDetails['uid'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        //print(doc['category']['mainCategory']);
        setState(() {
          _categoryList.add(doc['category']['mainCategory']);
        });
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);

    return FutureBuilder(
      future: _services.category.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something went wrong..'),
          );
        }
        if (_categoryList.length == 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Text(
                    'Maalesef bu dükkan için şuan ulaşılabilir bir ürün yok.',
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ),
                ),
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return Container();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      //bu kısımda resim yerine düz tema rengine arkaplan koyabiliriz.

                      // image: DecorationImage(
                      //   image: AssetImage('images/kbakkal_home_banner.png'),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    child: Center(
                      child: Text(
                        'KATEGORİLER',
                        style: TextStyle(
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          fontFamily: 'Lato-Regular.ttf',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Wrap(
                direction: Axis.horizontal,
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  return _categoryList.contains(document.data()['name'])
                      ? InkWell(
                          onTap: () {
                            _storeProvider
                                .getSelectedCategory(document.data()['name']);
                            _storeProvider.getSelectedSubCategory(null);

                            pushNewScreenWithRouteSettings(
                              context,
                              settings:
                                  RouteSettings(name: ProductListScreen.id),
                              screen: ProductListScreen(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            child: Card(
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 80,
                                    child:
                                        Image.network(document.data()['image']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: Text(
                                      document.data()['name'],
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Text('');
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
