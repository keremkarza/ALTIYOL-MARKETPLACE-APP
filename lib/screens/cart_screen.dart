import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/providers/auth_provider.dart';
import 'package:multivendor_app/providers/cart_provider.dart';
import 'package:multivendor_app/providers/coupon_provider.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:multivendor_app/screens/navbars/profile_screen.dart';
import 'package:multivendor_app/services/cart_services.dart';
import 'package:multivendor_app/services/order_services.dart';
import 'package:multivendor_app/services/store_services.dart';
import 'package:multivendor_app/services/user_services.dart';
import 'package:multivendor_app/widgets/cart/cart_list.dart';
import 'package:multivendor_app/widgets/cart/cod_toggle.dart';
import 'package:multivendor_app/widgets/cart/coupon_widget.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'starter/map_screen.dart';

class CartScreen extends StatefulWidget {
  final DocumentSnapshot document;

  CartScreen({this.document});

  static const String id = 'cart-screen';
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  UserServices _userServices = UserServices();
  CartServices _cartServices = CartServices();
  User user = FirebaseAuth.instance.currentUser;
  OrderServices _orderServices = OrderServices();
  StoreServices _store = StoreServices();
  DocumentSnapshot doc;
  double discount = 0;
  int deliveryFee = 4;
  var textStyle = TextStyle(
    color: Colors.grey,
    fontFamily: 'Lato-Regular.ttf',
  );
  String _address;
  //bool _loading = false;
  bool _checkingUser = false;

  @override
  void didChangeDependencies() {
    // getPrefs();
    // _store.getShopDetails(widget.document.data()['sellerUid']).then((value) {
    //   setState(() {
    //     doc = value;
    //   });
    // });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    getPrefs();
    _store.getShopDetails(widget.document.data()['sellerUid']).then((value) {
      setState(() {
        doc = value;
      });
    });
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString('address');

    setState(() {
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    //buna bakılması lazım tehlikeli
    // _store.getShopDetails(widget.document.data()['sellerUid']).then((value) {
    //   setState(() {
    //     doc = value;
    //   });
    // });
    setState(() {
      _checkingUser = false;
    });
    final locationData = Provider.of<LocationProvider>(context);
    var _cartProvider = Provider.of<CartProvider>(context);
    var userDetails = Provider.of<AuthProvider>(context);
    var _coupon = Provider.of<CouponProvider>(context);

    userDetails.getUserDetails().then((value) {
      double subTotal = _cartProvider.subTotal;
      double discountRate = _coupon.discountRate / 100;
      setState(() {
        discount = subTotal * discountRate;
      });
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(.0),
      bottomSheet: userDetails.snapshot == null
          ? Container()
          : Container(
              height: 140,
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(width: 1.5)),
                    ),
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Bu adrese teslim edilecek',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 13),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  EasyLoading.show(status: 'Lütfen Bekleyin..');
                                  locationData
                                      .getCurrentPosition()
                                      .then((value) {
                                    EasyLoading.showSuccess(
                                        'Teslimat bolgeni degistir.');
                                    if (value != null) {
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings:
                                            RouteSettings(name: MapScreen.id),
                                        screen: MapScreen(),
                                        withNavBar:
                                            false, // 4 nav ekranından farklı yere navigate ederken false
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                      );
                                    } else {
                                      EasyLoading.dismiss();
                                      print('permission not allowed');
                                    }
                                  });
                                },
                                child: Card(
                                  elevation: 4,
                                  color: Colors.red,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 10),
                                    child: Text(
                                      'Değiştir',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Lato-Regular.ttf'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            userDetails.snapshot == null
                                ? '$_address'
                                : userDetails.snapshot.data()['firstName'] !=
                                        null
                                    ? '${userDetails.snapshot.data()['firstName']} ${userDetails.snapshot.data()['lastName']} : $_address'
                                    : '$_address',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Lato-Regular.ttf'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_cartProvider.subTotal.toStringAsFixed(2)}\$',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '(Herşey Dahil)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontFamily: 'Lato-Regular.ttf'),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_cartProvider.subTotal >= 15) {
                                setState(() {
                                  _checkingUser = true;
                                });
                                _userServices
                                    .getUserById(user.uid)
                                    .then((value) {
                                  if (value.data()['id'] == null) {
                                    //need to confirm user name before placing order
                                    pushNewScreenWithRouteSettings(
                                      context,
                                      settings:
                                          RouteSettings(name: ProfileScreen.id),
                                      screen: ProfileScreen(),
                                      withNavBar: true,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  } else {
                                    //TODO:Payment gateway integration.
                                    //confirm payment method (cash/credit offline or pay online)
                                    _saveOrder(_cartProvider, _coupon);

                                    // setState(() {
                                    //   _checkingUser = false;
                                    // });
                                    // if (_cartProvider.index == 0) {
                                    //   print('online');
                                    // }
                                    // if (_cartProvider.index == 1) {
                                    //   print('cash');
                                    // }
                                    // if (_cartProvider.index == 2) {
                                    //   print('credit');
                                    // }
                                  }
                                });
                              } else {
                                _showMyDialog(
                                    title: 'SİPARİŞ VER',
                                    content:
                                        'You must buy products worth equal or more than 15 TL, Please buy more product to proceed.');
                              }
                            },
                            child: _checkingUser
                                ? CircularProgressIndicator()
                                : Text(
                                    'SİPARİŞ VER',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Lato-Regular.ttf'),
                                  ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                        (states) => Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBozIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.document.data()['shopName'],
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${_cartProvider.cartQty} Ürün için ', // ${_cartProvider.cartQty == 1 ? 'Item' : 'Items'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '  Tutar : ${_cartProvider.subTotal.toStringAsFixed(2)} TL',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        body: doc == null
            ? Center(child: CircularProgressIndicator())
            : _cartProvider.cartQty > 0
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 10),
                              ListTile(
                                title: Text(
                                  doc.data()['shopName'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Lato-Regular.ttf'),
                                ),
                                subtitle: Text(
                                  doc.data()['address'],
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontFamily: 'Lato-Regular.ttf'),
                                ),
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  child: doc == null
                                      ? Container()
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            doc.data()['url'],
                                            fit: BoxFit.cover,
                                          )),
                                ),
                              ),
                              CodToggleSwitch(),
                              //Divider(color: Colors.grey),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Divider(thickness: 2, color: Colors.black),
                          ),
                          CartList(document: widget.document),
                          //Coupon Card
                          if (doc != null)
                            CouponWidget(
                              couponVendor: doc.data()['uid'],
                            ),
                          //Bill Details Card
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 80, top: 4, left: 4, right: 4),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fatura Detayları',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('Sepet Tutarı',
                                                  style: textStyle)),
                                          Text(
                                              '${_cartProvider.subTotal.toStringAsFixed(2)} TL',
                                              style: textStyle),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('İndirim',
                                                  style: textStyle)),
                                          Text(
                                              discount > 0
                                                  ? '${discount.toStringAsFixed(2)} TL'
                                                  : 'INDIRIM YOK',
                                              style: textStyle),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('Teslimat Ücreti',
                                                  style: textStyle)),
                                          Text(
                                              '${deliveryFee.toStringAsFixed(2)} TL',
                                              style: textStyle),
                                        ],
                                      ),
                                      Divider(color: Colors.grey),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  'Ödenecek toplam tutar : ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          //Aşagı kısımda 30$ discount her türlü düşüyor, böylece - olabiliyor
                                          // bu kısım çözülmeli
                                          Text(
                                              '${(deliveryFee + _cartProvider.subTotal - discount).toStringAsFixed(2)} TL',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Theme.of(context)
                                              .secondaryHeaderColor
                                              .withOpacity(.2),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                'Son Kazanç',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'Lato-Regular.ttf',
                                                ),
                                              )),
                                              Text(
                                                  '${_cartProvider.saving.toStringAsFixed(2)} TL',
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Sepetin Boş, bizimle siparişe devam edin.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lato-Regular.ttf',
                      ),
                    ),
                  ),
      ),
    );
  }

  _saveOrder(CartProvider cartProvider, CouponProvider couponProvider) {
    if (cartProvider.index != 0) {
      _orderServices.saveOrder({
        'products': cartProvider.cartList,
        'userId': user.uid,
        'deliveryFee': deliveryFee,
        'total':
            (deliveryFee + cartProvider.subTotal - discount).toStringAsFixed(2),
        'discount': discount.toStringAsFixed(2),
        'cod': cartProvider.index, // which payment path
        'discountCode': couponProvider.document == null
            ? null
            : couponProvider.document.data()['title'],
        'seller': {
          'shopName': widget.document.data()['shopName'],
          'sellerId': widget.document.data()['sellerUid'],
          'timeStamp': DateTime.now().toString(),
          'orderStatus': 'Ordered',
        },
        'deliveryBoy': {
          'name': '',
          'phone': '',
          'location': GeoPoint(0, 0),
          'email': '',
        }
      }).then((value) {
        //after submitting order, need to clear cart list.
        _cartServices.deleteCart().then((value) {
          _cartServices.checkData().then((value) {
            EasyLoading.showSuccess('Siparisin gönderildi.');
            Navigator.pop(context);
          });
        });
      });
    } else {
      //index 0'sa yani onlinesa
      _showMyDialog(
          title: 'Online Sipariş',
          content:
              'Siparişinin online olmasını seçtin ama maalesef henüz bu özelliğimiz aktif değil.');
    }
  }

  Future<void> _showMyDialog({content, title}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
          ),
          titleTextStyle: TextStyle(color: Colors.red),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  content,
                  style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                ),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('TAMAM'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
