import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/store_provider.dart';
import 'package:multivendor_app/services/product_services.dart';
import 'package:multivendor_app/widgets/products/products_card_widget.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    var _storeProvider = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: _services.products
          .where('published', isEqualTo: true)
          .where('category.mainCategory',
              isEqualTo: _storeProvider.selectedProductCategory)
          .where('category.subCategory',
              isEqualTo: _storeProvider.selectedSubProductCategory)
          .where('seller.sellerUid',
              isEqualTo: _storeProvider.storeDetails['uid'])
          .orderBy('invQuantity', descending: true)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData) {
          print('bos');
          return Container();
        }
        if (snapshot.data.docs.isEmpty) {
          return Container(); // if no data
        }
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.lightGreen[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${snapshot.data.docs.length} Ürün',
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
                      fontFamily: 'Lato-Regular.ttf'),
                ),
              ),
            ),
            new ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                return new ProductCard(document: document);
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
