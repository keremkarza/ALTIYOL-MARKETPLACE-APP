import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/widgets/categories_widget.dart';
import 'package:multivendor_app/widgets/products/best_selling_products.dart';
import 'package:multivendor_app/widgets/products/featured_products.dart';
import 'package:multivendor_app/widgets/products/recently_added_products.dart';
import 'package:multivendor_app/widgets/vendor_appbar.dart';
import 'package:multivendor_app/widgets/vendor_banner.dart';

class VendorHomeScreen extends StatelessWidget {
  static const String id = 'vendor-home-screen';
  //String vendorUid;
  @override
  Widget build(BuildContext context) {
    print('vendorhome build');
    //var _store = Provider.of<StoreProvider>(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            VendorAppBar(),
          ];
        },
        body: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            VendorBanner(),
            VendorCategories(),
            RecentlyAddedProducts(),
            FeaturedProducts(),
            BestSellingProducts(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
