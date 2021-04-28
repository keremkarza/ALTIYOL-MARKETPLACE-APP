import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const NUMBER = 'number'; //to avoid any typos
  static const ID = 'ID';

  String _number;
  String _id;

  //getters
  String get number => _number;
  String get id => _id;

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _number = snapshot.data()[NUMBER];
    _id = snapshot.data()[ID];
  }
}
