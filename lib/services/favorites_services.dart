import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouritesServices {
  CollectionReference favourites =
      FirebaseFirestore.instance.collection('favourites');
  User user = FirebaseAuth.instance.currentUser;

  getFavouritesItems() {
    return favourites.where('customerId', isEqualTo: user.uid).snapshots();
  }

  Future<bool> checkFavouriteItem(productId) async {
    var result = favourites
        .where('customerId', isEqualTo: user.uid)
        .where('product.productId', isEqualTo: productId)
        .limit(10)
        .snapshots();

    bool empty = await result.first != null ? true : false;
    print(empty);
    return empty;
  }

  Future<DocumentSnapshot> getProductDetails(sellerUid) async {
    //seller uid kısmına bakıp favoritteki doc idyi getirmemiz gerek
    DocumentSnapshot snapshot = await favourites.doc(sellerUid).get();
    return snapshot;
  }
}
