import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:multivendor_app/services/cart_services.dart';

class CartProvider with ChangeNotifier {
  CartServices _cart = CartServices();
  double subTotal = 0.0;
  int cartQty = 0;
  QuerySnapshot snapshot;
  DocumentSnapshot document;
  double saving = 0.0;
  double distance;
  int index = 0;
  List cartList = [];

  // void getNotify() {
  //   notifyListeners();
  // }

  // int getCartQtyFromProvider() {
  //   print('cartQty : ${this.cartQty}');
  //   return this.cartQty;
  // }

  // double getDistanceFromProvider() {
  //   print('distance : ${this.distance}');
  //   return this.distance;
  // }

  Future<double> getCartTotal() async {
    //print('getTotalInCartProvider');
    var saving = 0.0;
    var cartTotal = 0.0;
    List _newList = [];
    QuerySnapshot snapshot =
        await _cart.cart.doc(_cart.user.uid).collection('products').get();

    if (snapshot == null) {
      return null;
    }

    snapshot.docs.forEach((doc) {
      if (!_newList.contains(doc.data())) {
        _newList.add(doc.data());
        this.cartList = _newList;
        notifyListeners();
      }
      cartTotal = cartTotal + doc.data()['total'];
      saving = saving +
          ((doc.data()['comparedPrice'] - doc.data()['price']) *
                      doc.data()['qty'] >
                  0
              ? (doc.data()['comparedPrice'] - doc.data()['price']) *
                  doc.data()['qty']
              : 0);
    });

    this.subTotal = cartTotal;
    this.cartQty = snapshot.size;
    this.snapshot = snapshot;
    this.saving = saving;
    notifyListeners();

    return cartTotal;
  }

  getDistance(distance) {
    //print('getDistanceInCartProvider');
    this.distance = distance;
    notifyListeners();
  }

  getPaymentMethod(index) {
    print('getPaymentInCartProvider');
    if (index == 0) {
      this.index = 0;
      print(0);
      notifyListeners();
    }
    if (index == 1) {
      this.index = 1;
      print(1);
      notifyListeners();
    }
    if (index == 2) {
      this.index = 2;
      print(2);
      notifyListeners();
    }
  }

  //Future<DocumentSnapshot>
  Future<DocumentSnapshot> getShopName() async {
    //print('getShopInCartProvider');
    DocumentSnapshot doc = await _cart.cart.doc(_cart.user.uid).get();
    if (doc.exists) {
      this.document = doc;
      notifyListeners();
    } else {
      this.document = null;
      notifyListeners();
    }
    return doc;
  }
}
