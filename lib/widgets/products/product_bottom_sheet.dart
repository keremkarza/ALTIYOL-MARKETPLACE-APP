import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/widgets/cart/add_to_cart_widget.dart';
import 'package:multivendor_app/widgets/cart/save_for_later_widget.dart';

class ProductBottomSheet extends StatefulWidget {
  final DocumentSnapshot document;
  const ProductBottomSheet({Key key, this.document}) : super(key: key);

  @override
  _ProductBottomSheetState createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        children: [
          Flexible(
              flex: 1, child: SaveForLaterWidget(document: widget.document)),
          Flexible(flex: 1, child: AddToCartWidget(document: widget.document)),
        ],
      ),
    );
  }
}
