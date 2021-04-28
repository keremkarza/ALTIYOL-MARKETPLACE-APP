import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/widgets/cart/counter.dart';

class CartCard extends StatelessWidget {
  final DocumentSnapshot document;

  CartCard({this.document});
  @override
  Widget build(BuildContext context) {
    double discount = 100 -
        ((document.data()['price'] / document.data()['comparedPrice']) * 100);
    int intDiscount = discount.toInt();
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey))),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: intDiscount >= 10
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Banner(
                              message: '% $intDiscount',
                              location: BannerLocation.topEnd,
                              child: Image.network(
                                document.data()['productImage'],
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : Image.network(
                            document.data()['productImage'],
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.data()['productName'],
                        maxLines: 1,
                        style: TextStyle(),
                      ),
                      Row(
                        children: [
                          Text(
                            '1',
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(context).backgroundColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            document.data()['weight'],
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(context).backgroundColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${document.data()['price'].toStringAsFixed(2)}\$',
                            maxLines: 1,
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${(document.data()['comparedPrice']).toStringAsFixed(2)}\$',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            child: CounterForCard(document: document),
            right: 5,
            bottom: 5,
          ),
        ],
      ),
    );
  }
}
