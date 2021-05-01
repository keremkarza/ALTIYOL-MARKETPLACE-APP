import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/services/cart_services.dart';

class CounterWidget extends StatefulWidget {
  final DocumentSnapshot document;
  final String docId;
  final int qty;
  const CounterWidget({Key key, this.document, this.qty, this.docId})
      : super(key: key);

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  CartServices _cart = CartServices();
  User user = FirebaseAuth.instance.currentUser;
  int _qty;
  bool _updating = false;
  bool _exists = true;
  bool _deleted = false;

  getCartData() async {
    final snapshot =
        await _cart.cart.doc(user.uid).collection('products').get();
    if (snapshot.docs.length == 0) {
      //means this product not added to cart
      setState(() {
        _updating = false;
      });
    } else {
      setState(() {
        _updating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('counterwidget build');
    setState(() {
      _qty = widget.qty;
    });
    return !_exists
        ? Container(
            child: TextButton(
              child: Container(
                child: Center(
                  child: Text(
                    'GERİ GİT',
                    style: TextStyle(
                        fontFamily: 'Lato-Regular.ttf', color: Colors.white),
                  ),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        : Container(
            margin: EdgeInsets.only(left: 0, right: 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent[700], width: 5),
            ),
            height: 56,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(3),
                child: FittedBox(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                          });
                          if (_qty == 1) {
                            _cart.removeFromCart(widget.docId).then((value) {
                              setState(() {
                                _updating = false;
                                _exists = false;
                                _deleted = true;
                              });

                              _cart.checkData();
                            });
                          }
                          if (_qty > 1) {
                            setState(() {
                              _qty--;
                            });
                            var total = _qty * widget.document.data()['price'];
                            _cart
                                .updateCartQty(widget.docId, _qty, total)
                                .then((value) {
                              setState(() {
                                _updating = false;
                              });
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.greenAccent[700])),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _qty == 1 ? Icons.delete_outlined : Icons.remove,
                              color: Colors.greenAccent[700],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 8, bottom: 8),
                          child: _updating
                              ? Container(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.greenAccent[700]),
                                  ))
                              : Text(
                                  _qty.toString(),
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                            _qty++;
                          });
                          var total = _qty * widget.document.data()['price'];
                          _cart
                              .updateCartQty(widget.docId, _qty, total)
                              .then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.greenAccent[700]),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.greenAccent[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  // showMyDialog(shopName) {
  //   showCupertinoDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return CupertinoAlertDialog(
  //           title: Text('Sepetinizi sıfırlayalım mı?'),
  //           content: Text(
  //               'Sepetinde $shopName dükkanından ürünler var. Bu sepeti silmemizi ve ${widget.document.data()['seller']['shopName']} dükkanından bu ürünü eklememizi istermisin?'),
  //           actions: [
  //             TextButton(
  //               child: Text('Hayır'),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             TextButton(
  //               child: Text('Evet'),
  //               onPressed: () {
  //                 //delete existing cart
  //                 _cart.deleteCart().then((value) {
  //                   _cart.addToCart(widget.document).then((value) {
  //                     setState(() {
  //                       _exists = true;
  //                     });
  //                     Navigator.pop(context);
  //                     EasyLoading.showSuccess('Added to Cart');
  //                   });
  //                 });
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }
}
