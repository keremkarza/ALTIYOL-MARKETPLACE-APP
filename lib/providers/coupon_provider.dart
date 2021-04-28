import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CouponProvider with ChangeNotifier {
  bool expired;
  DocumentSnapshot document;
  int discountRate = 0;
  getCouponDetails(title, sellerUid) async {
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('coupons').doc(title).get();
    if (document.exists) {
      this.document = document;
      notifyListeners();
      print('exists');
      print('1: $sellerUid');
      print(document.data()['sellerUid']);
      if (document.data()['sellerUid'] == sellerUid) {
        print('check');
        checkExpiry(document);
      }
    } else {
      this.document = null;
      notifyListeners();
    }
  }

  checkExpiry(DocumentSnapshot document) {
    DateTime date = document.data()['expiry'].toDate();
    var dateDiff = date.difference(DateTime.now()).inDays;
    if (dateDiff < 0) {
      print('expired');
      //coupon expired
      this.expired = true;
      notifyListeners();
    } else {
      print('false');
      this.document = document;
      this.expired = false;
      this.discountRate = document.data()['discountRate'];
      notifyListeners();
    }
  }
}
