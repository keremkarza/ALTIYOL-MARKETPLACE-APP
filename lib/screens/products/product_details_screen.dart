import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/widgets/products/product_bottom_sheet.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String id = 'product-details-screen';
  final DocumentSnapshot document;
  final bool isFromNavBar;

  const ProductDetailsScreen({Key key, this.document, this.isFromNavBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openedDocument = document.data()['product'] != null
        ? document.data()['product']
        : document.data();
    double discount = 100 -
        ((openedDocument['price'] / openedDocument['comparedPrice']) * 100);
    int intDiscount = discount.toInt();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        actions: [
          Visibility(
            visible: false,
            child: IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.search),
            ),
          ),
        ],
      ),
      //bu kısma giden document kontrolü yapılmadı, 2 türlüsüde gidebilir.
      bottomSheet: isFromNavBar
          ? Container(height: 2)
          : ProductBottomSheet(document: document),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, bottom: 2, top: 2),
                    child: Text(openedDocument['brand']),
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.3),
                      border:
                          Border.all(color: Theme.of(context).primaryColor)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(openedDocument['productName'], style: TextStyle(fontSize: 22)),
            SizedBox(height: 10),
            Text(
              '1 ${openedDocument['weight']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('${openedDocument['price'].toStringAsFixed(0)}\$',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text(
                  '${openedDocument['comparedPrice'].toStringAsFixed(0)}\$',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: intDiscount >= 10
                    ? Banner(
                        color: Colors.red,
                        message: '% ${intDiscount}',
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900),
                        location: BannerLocation.topStart,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Hero(
                            tag: 'product${openedDocument['productName']}',
                            child: Image.network(
                              openedDocument['productImage'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        child: Hero(
                          tag: 'product${openedDocument['productName']}',
                          child: Image.network(
                            openedDocument['productImage'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
            ),
            Divider(thickness: 6, color: Colors.grey[400]),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'About this product',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(color: Colors.grey[300]),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
              child: ExpandableText(
                openedDocument['description'],
                expandText: 'View More',
                collapseText: 'View Less',
                maxLines: 2,
                linkColor: Colors.blue,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Other Product Info',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(thickness: 6, color: Colors.grey[400]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU : ${openedDocument['sku']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Seller : ${openedDocument['seller']['shopName']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
      //body: Container(),
    );
  }
}
