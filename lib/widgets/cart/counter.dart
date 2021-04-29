import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/services/cart_services.dart';
import 'package:multivendor_app/widgets/cart/add_to_cart_widget.dart';

class CounterForCard extends StatefulWidget {
  final DocumentSnapshot document;
  const CounterForCard({Key key, this.document}) : super(key: key);

  @override
  _CounterForCardState createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {
  User user = FirebaseAuth.instance.currentUser;
  CartServices _cartServices = CartServices();
  bool _loading = true;
  bool _exist = false;
  int _qty = 1;
  String _docId;
  bool _updating = false;

  @override
  void didChangeDependencies() {
    print('didchangeInCounter?');
    getCartData();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() {
    print('getCartData');
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document.data()['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          if (doc["productId"] == widget.document.data()['productId']) {
            //means selected product already exists in cart, so no need to add to cart again
            //SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
            _exist = true;
            _qty = doc['qty'];
            _docId = doc.id;
            //}));
          }
        });
      } else {
        //SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
        _exist = false;
        //}));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('counterforcard build');
    // SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
    //       getCartData();
    //     }));
    return !_exist
        ? StreamBuilder(
            stream: getCartData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print('StreamBuilder1 build');
              return InkWell(
                onTap: () {
                  print('add00 : $_qty');
                  EasyLoading.show(status: 'Adding to Cart');
                  _cartServices.checkSeller().then((shopName) {
                    if (shopName == null) {
                      setState(() {
                        _exist = true;
                        //_qty++;
                      });
                      print('add01 : $_qty');
                      _cartServices.addToCart(widget.document).then((value) {
                        EasyLoading.showSuccess('Added to Cart');
                      });
                      // WidgetsBinding.instance
                      //     .addPostFrameCallback((_) => setState(() {
                      //           getCartData();
                      //         }));
                      return;
                    }
                    if (shopName ==
                        widget.document.data()['seller']['shopName']) {
                      //product from same seller
                      setState(() {
                        _exist = true;
                        //_qty++;
                      });
                      print('add01 : $_qty');
                      _cartServices.addToCart(widget.document).then((value) {
                        EasyLoading.showSuccess('Added to Cart');
                      });
                      // WidgetsBinding.instance
                      //     .addPostFrameCallback((_) => setState(() {
                      //           getCartData();
                      //         }));
                      return;
                    } else {
                      //product from different seller
                      EasyLoading.dismiss();
                      showDialog(shopName);

                      return;
                    }
                  });
                },
                child: Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  height: 28,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4)),
                ),
              );
            })
        : StreamBuilder(
            stream: getCartData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print('StreamBuilder2 build');
              return !_exist
                  ? buildAddToCartWidget()
                  : Container(
                      height: 28,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _updating = true;
                              });
                              if (_qty == 1) {
                                _cartServices
                                    .removeFromCart(_docId)
                                    .then((value) {
                                  EasyLoading.show(status: 'Removing...');
                                  setState(() {
                                    _updating = false;
                                    _exist = false;
                                  });
                                  EasyLoading.showSuccess('Removed');

                                  _cartServices.checkData();
                                });
                              }
                              if (_qty > 1) {
                                setState(() {
                                  _qty--;
                                });
                                var total =
                                    _qty * widget.document.data()['price'];
                                _cartServices
                                    .updateCartQty(_docId, _qty, total)
                                    .then((value) {
                                  setState(() {
                                    _updating = false;
                                  });
                                });
                              }
                            },
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: _qty == 1
                                    ? Icon(Icons.delete_outlined,
                                        color: Theme.of(context).primaryColor)
                                    : Icon(Icons.remove,
                                        color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          Container(
                            height: double.infinity,
                            width: 30,
                            color: Theme.of(context).primaryColor,
                            child: Center(
                                child: FittedBox(
                                    child: _updating
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(_qty.toString(),
                                            style: TextStyle(
                                                color: Colors.white)))),
                          ),
                          InkWell(
                            onTap: () {
                              print('add1 : $_qty');
                              setState(() {
                                // if (_qty == 1) {
                                //   _qty++;
                                // }
                                _updating = true;
                                ++_qty;
                              });
                              print('add2 : $_qty');
                              var total =
                                  _qty * widget.document.data()['price'];
                              _cartServices
                                  .updateCartQty(_docId, _qty, total)
                                  .then((value) {
                                setState(() {
                                  _updating = false;
                                });
                              });
                            },
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Icon(Icons.add,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            });
  }

  AddToCartWidget buildAddToCartWidget() {
    return AddToCartWidget(document: widget.document);
  }

  showDialog(shopName) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Replace Cart item?'),
            content: Text(
                'Your cart contains items from $shopName. Do you want to discard the selection and add items from ${widget.document.data()['seller']['shopName']}'),
            actions: [
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  //delete existing cart
                  _cartServices.deleteCart().then((value) {
                    _cartServices.addToCart(widget.document).then((value) {
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
