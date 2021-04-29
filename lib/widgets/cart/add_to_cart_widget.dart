import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/services/cart_services.dart';

import 'counter_widget.dart';

class AddToCartWidget extends StatefulWidget {
  final DocumentSnapshot document;
  const AddToCartWidget({Key key, this.document}) : super(key: key);

  @override
  _AddToCartWidgetState createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  User user = FirebaseAuth.instance.currentUser;
  CartServices _cart = CartServices();
  bool _loading = true;
  bool _exist = false;
  int _qty = 1;
  String _docId;

  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() async {
    final snapshot =
        await _cart.cart.doc(user.uid).collection('products').get();
    if (snapshot.docs.length == 0) {
      //means this product not added to cart
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if this product exists in cart, we need to get qty details
    print('AddToCartWidget build');

    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document.data()['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["productId"] == widget.document.data()['productId']) {
          //means selected product already exists in cart, so no need to add to cart again
          setState(() {
            _exist = true;
            _qty = doc['qty'];
            _docId = doc.id;
          });
        }
      });
    });

    return Container(
      child: _loading
          ? Container(
              height: 56,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
            )
          : _exist
              ? CounterWidget(
                  document: widget.document, qty: _qty, docId: _docId)
              : InkWell(
                  onTap: () {
                    print(_qty);
                    EasyLoading.show(status: 'Sepete Ekleniyor..');
                    _cart.checkSeller().then((shopName) {
                      if (shopName == null) {
                        setState(() {
                          _exist = true;
                        });
                        _cart.addToCart(widget.document).then((value) {
                          EasyLoading.showSuccess('Sepete Eklendi');
                        });
                        return;
                      }
                      if (shopName ==
                          widget.document.data()['seller']['shopName']) {
                        //product from same seller
                        setState(() {
                          _exist = true;
                        });
                        _cart.addToCart(widget.document).then((value) {
                          EasyLoading.showSuccess('Sepete Eklendi');
                        });
                        return;
                      } else {
                        //product from different seller
                        EasyLoading.dismiss();
                        showDialog(shopName);
                        return;
                      }
                    });
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => setState(() {
                              getCartData();
                            }));
                  },
                  child: Container(
                    height: 56,
                    color: Theme.of(context).backgroundColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(width: 15),
                            Icon(Icons.shopping_basket_outlined,
                                color: Colors.white),
                            SizedBox(width: 10),
                            Text('SEPETE EKLE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  showDialog(shopName) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Sepetinizi sıfırlayalım mı?'),
            content: Text(
                'Sepetinde $shopName dükkanından ürünler var. Bu sepeti silmemizi ve ${widget.document.data()['seller']['shopName']} dükkanından bu ürünü eklememizi istermisin?'),
            actions: [
              TextButton(
                child: Text('Hayır'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Evet'),
                onPressed: () {
                  //delete existing cart
                  _cart.deleteCart().then((value) {
                    _cart.addToCart(widget.document).then((value) {
                      setState(() {
                        _exist = true;
                      });
                      Navigator.pop(context);
                      EasyLoading.showSuccess('Added to Cart');
                    });
                  });
                },
              ),
            ],
          );
        });
  }
}
