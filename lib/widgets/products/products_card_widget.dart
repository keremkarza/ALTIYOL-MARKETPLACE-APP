import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/screens/products/product_details_screen.dart';
import 'package:multivendor_app/widgets/cart/counter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProductCard extends StatelessWidget {
  final DocumentSnapshot document;

  const ProductCard({Key key, this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print('productcard build');
    double discount = 100 -
        ((document.data()['price'] / document.data()['comparedPrice']) * 100);
    int intDiscount = discount.toInt();
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey[300]),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 8.0, bottom: 8, left: 10, right: 10),
        child: Row(
          children: [
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(name: ProductDetailsScreen.id),
                    screen: ProductDetailsScreen(
                      document: document,
                      isFromNavBar: false,
                    ),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: SizedBox(
                  height: 140,
                  width: 130,
                  child: Container(
                    //we may add BoxFit feature in this image
                    child: intDiscount >= 30
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Banner(
                              child: Hero(
                                tag: 'product${document.data()['productName']}',
                                child: Image.network(
                                    document.data()['productImage']),
                              ),
                              message: '% $intDiscount',
                              location: BannerLocation.topEnd,
                            ),
                          )
                        : Hero(
                            tag: 'product${document.data()['productName']}',
                            child:
                                Image.network(document.data()['productImage']),
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document.data()['brand'],
                          style: TextStyle(fontSize: 10)),
                      SizedBox(height: 6),
                      Text(document.data()['productName'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Container(
                        width: MediaQuery.of(context).size.width - 160,
                        padding:
                            const EdgeInsets.only(top: 10, bottom: 10, left: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[200],
                        ),
                        child: Text('1 ${document.data()['weight']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey[600],
                            )),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '${document.data()['price'].toStringAsFixed(0)} TL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '${document.data()['comparedPrice'].toStringAsFixed(0)} TL',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CounterForCard(document: document),
                        // Card(
                        //   color: Colors.redAccent,
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(
                        //         left: 30, right: 30, top: 7, bottom: 7),
                        //     child: Text(
                        //       'Add',
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.white),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
