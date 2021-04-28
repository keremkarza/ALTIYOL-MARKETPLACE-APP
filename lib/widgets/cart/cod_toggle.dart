import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_bar/toggle_bar.dart';

class CodToggleSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _cart = Provider.of<CartProvider>(context);

    return Container(
      color: Colors.transparent,
      child: ToggleBar(
          backgroundColor: Theme.of(context).primaryColor,
          labels: ["Online", "Cash at Door", "Cart at Door"],
          //labelTextStyle: TextStyle(),
          selectedTabColor: Colors.white,
          selectedTextColor: Colors.black,
          onSelectionUpdated: (index) {
            _cart.getPaymentMethod(index);
          } // Do something with index
          ),
    );
  }
}
