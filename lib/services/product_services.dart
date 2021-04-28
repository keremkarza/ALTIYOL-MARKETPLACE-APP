import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServices {
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');
  CollectionReference category =
      FirebaseFirestore.instance.collection('categories');

  // getTopPickedStores() {
  //   return FirebaseFirestore.instance
  //       .collection('vendors')
  //       .where('accVerified', isEqualTo: true)
  //       .where('isTopPicked', isEqualTo: true)
  //       .where('shopOpen', isEqualTo: true)
  //       .orderBy('shopName')
  //       .snapshots();
  // }
  //
  // getNearByStores() {
  //   return FirebaseFirestore.instance
  //       .collection('vendors')
  //       .where('accVerified', isEqualTo: true)
  //       .orderBy('shopName')
  //       .snapshots();
  // }
  //
  // getNearByStoresPagination() {
  //   return FirebaseFirestore.instance
  //       .collection('vendors')
  //       .where('accVerified', isEqualTo: true)
  //       .orderBy('shopName');
  // }
}
