import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderServices {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<DocumentReference> saveOrder(Map<String, dynamic> data) {
    var result = orders.add(data);
    return result;
  }

  Color statusColor(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    } else if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return Colors.red;
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return Colors.purple[900];
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return Colors.green;
    } else {
      return Colors.orangeAccent;
    }
  }

  String statusString(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Accepted') {
      return "Kabul Edildi";
    } else if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return "Reddedildi";
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return "Hazırlanıyor";
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return "Yolda";
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return "Teslim Edildi";
    } else {
      return "Sipariş Verildi";
    }
  }

  Icon statusIcon(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Accepted') {
      return Icon(Icons.check, color: statusColor(document), size: 18);
    } else if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return Icon(Icons.highlight_remove_outlined,
          color: statusColor(document));
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return Icon(Icons.upgrade_outlined,
          color: statusColor(document), size: 18);
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return Icon(Icons.delivery_dining,
          color: statusColor(document), size: 18);
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return Icon(Icons.shopping_bag_outlined,
          color: statusColor(document), size: 18);
    } else {
      return Icon(Icons.assignment_turned_in_outlined,
          color: statusColor(document), size: 18);
    }
  }

  String statusComment(DocumentSnapshot document) {
    if (document.data()['seller']['orderStatus'] == 'Rejected') {
      return 'Your order is Rejected by ${document.data()['deliveryBoy']['name']}';
    } else if (document.data()['seller']['orderStatus'] == 'On the way') {
      return 'Your delivery carrier ${document.data()['deliveryBoy']['name']} is on the way';
    } else if (document.data()['seller']['orderStatus'] == 'Picked Up') {
      return 'Your order is Picked Up by ${document.data()['deliveryBoy']['name']}';
    } else if (document.data()['seller']['orderStatus'] == 'Delivered') {
      return 'Your order is Delivered by ${document.data()['deliveryBoy']['name']}';
    } else {
      return 'Your order is Accepted by ${document.data()['seller']['shopName']}';
    }
  }
}
