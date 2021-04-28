import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/services/favorites_services.dart';

class SaveForLaterWidget extends StatelessWidget {
  final DocumentSnapshot document;
  const SaveForLaterWidget({Key key, this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Future<bool> isSaved;
    FavouritesServices _services = FavouritesServices();
    return Container(
      child: InkWell(
        onTap: () {
          _services
              .checkFavouriteItem(document.data()['productId'])
              .then((value) {
            if (value) {
              EasyLoading.show(status: 'Saving...');
              saveForLater().then((value) {
                EasyLoading.showSuccess('Saved Successfully');
              });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text('Save Item'),
                      content: Text('You already saved this item.'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            }
          });
        },
        child: Container(
          height: 56,
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 15),
                  Icon(CupertinoIcons.bookmark, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Save for later',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveForLater() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;
    return _favourite.add({
      'product': document.data(),
      'customerId': user.uid,
    });
  }
}
