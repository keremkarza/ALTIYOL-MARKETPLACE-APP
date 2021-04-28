import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/cart_provider.dart';
import 'package:multivendor_app/screens/cart_screen.dart';
import 'package:multivendor_app/services/cart_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

class CartNotification extends StatefulWidget {
  // CartProvider data = CartProvider();
  //
  // CartNotification({this.data});

  @override
  _CartNotificationState createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {
  CartServices _cartServices = CartServices();
  //DocumentSnapshot document;
  bool _loaded = false;
  final String url = 'şuanlık boş';

  @override
  void didChangeDependencies() {
    // if (_cartServices.didChangeTime) {
    //   _cartServices.didChangeTime = false;
    //   print(_cartServices.didChangeTime);
    //_filterInStart();
    //}
    super.didChangeDependencies();
  }

  @override
  void initState() {
    //_showMyDialog();
    _filterInStart().then((value) => _showMyDialog());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context, listen: true);
    //Future<DocumentSnapshot> shopFuture = _cartProvider.getShopName();
    //Future<double> cartFuture = _cartProvider.getCartTotal();
    _cartProvider
        .getCartTotal(); // bu kapanınca cart notification visible olmuyor.
    _cartProvider.getShopName().then((value) {
      // bu kapanınca cart notification shopname gelmiyor
      setState(() {
        _loaded = true;
      });
    });

    print('distance pro ${_cartProvider.distance}');

    print('cartNotification build');
    return Visibility(
      visible: _cartProvider.distance == null
          ? false
          : _cartProvider.distance <= 10
              ? _cartProvider.cartQty > 0
                  ? true
                  : false
              : false,
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_cartProvider.cartQty} ${_cartProvider.cartQty == 1 ? 'Item' : 'Items'}  ',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '|  ${_cartProvider.subTotal.toStringAsFixed(2)}\$',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      _cartProvider.document == null
                          ? ''
                          : _loaded
                              ? 'From ${_cartProvider.document.data() == null ? '' : _cartProvider.document.data()['shopName']}'
                              : '',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 8),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(name: CartScreen.id),
                    screen: CartScreen(document: _cartProvider.document),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        'View Cart',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _filterInStart() async {
    await Future.delayed(Duration(milliseconds: 50));
    final _cartProvider = Provider.of<CartProvider>(context, listen: false);
    //SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {

    _cartProvider
        .getCartTotal(); // bu kapanınca cart notification visible olmuyor.
    _cartProvider.getShopName().then((value) {
      // bu kapanınca cart notification shopname gelmiyor
      setState(() {
        _loaded = true;
      });
    });

    //eski hal
    // _cartServices.getShopName().then((value) {
    //   setState(() {
    //     _loaded = true;
    //     document = value;
    //   });
    // });
    //}));

    //do something
  }

  _showMyDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Can you share this app with your neighbours and friends in order for our vendors to reach out more ?",
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Lato-Regular.ttf',
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 320.0,
                      child: Container(
                        color: const Color(0xFF1BC0C5),
                        child: TextButton(
                          onPressed: () {
                            SocialShare.shareWhatsapp(
                                "Merhabalar, bizim mahallemizdeki esnaflara kolayca ulaşabileceğimiz bir uygulama buldum. Sizin de kullanmanızı tavsiye ediyorum. Bu linkten ulaşabilirsiniz --> $url ");
                          },
                          child: Text(
                            "Paylaş",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Lato-Regular.ttf'),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
