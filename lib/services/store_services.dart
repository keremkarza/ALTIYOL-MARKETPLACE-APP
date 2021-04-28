import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multivendor_app/providers/store_provider.dart';

class StoreServices {
  CollectionReference vendorBanner =
      FirebaseFirestore.instance.collection('vendorBanners');

  CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');

  getTopPickedStores() {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('isTopPicked', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName')
        .snapshots();
  }
  //getNearByStores(_storeData, tag)

  getNearByStores(StoreProvider storeProvider, tag) {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .where('superCategory',
            isEqualTo: tag > 0 ? storeProvider.status : null)
        .orderBy('shopName')
        .snapshots();
  }

  getNearByStoresPagination(StoreProvider storeProvider, tag) {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .where('superCategory',
            isEqualTo: tag > 0 ? storeProvider.status : null)
        .orderBy('shopName');
  }

  Future<DocumentSnapshot> getShopDetails(sellerUid) async {
    print('shopDetails');
    DocumentSnapshot snapshot = await vendors.doc(sellerUid).get();
    return snapshot;
  }
}
