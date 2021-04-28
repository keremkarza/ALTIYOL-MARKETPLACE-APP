import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/providers/coupon_provider.dart';
import 'package:provider/provider.dart';

class CouponWidget extends StatefulWidget {
  final String couponVendor;

  CouponWidget({this.couponVendor});

  @override
  _CouponWidgetState createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  Color color = Colors.grey;
  bool _enable = false;
  var _couponController = TextEditingController();
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    var _couponProvider = Provider.of<CouponProvider>(context);
    return Container(
      //margin: EdgeInsets.only(bottom: 56),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _couponController,
                      onChanged: (String value) {
                        if (value.length < 3) {
                          setState(() {
                            color = Colors.grey;
                            _enable = false;
                          });
                          if (value.isNotEmpty) {
                            setState(() {
                              color = Theme.of(context).primaryColor;
                              _enable = true;
                            });
                          }
                        }
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        //contentPadding: EdgeInsets.zero,
                        hintText: 'Enter Voucher Code',
                        contentPadding: EdgeInsets.all(8),
                        hintStyle:
                            TextStyle(color: Theme.of(context).backgroundColor),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                AbsorbPointer(
                  absorbing: _enable ? false : true,
                  child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => color)),
                    onPressed: () {
                      EasyLoading.show(status: 'Validating Coupon..');
                      _couponProvider
                          .getCouponDetails(
                              _couponController.text, widget.couponVendor)
                          .then((value) {
                        EasyLoading.dismiss();
                        if (value != null) {
                          if (value.data() == null) {
                            //_couponProvider.document == null can be useful here
                            print('not valid');
                            setState(() {
                              _couponProvider.discountRate = 0;
                              _visible = false;
                            });
                            EasyLoading.dismiss();
                            showDialog(
                                _couponController.text, context, 'Not valid');
                            return;
                          }
                        }
                        if (_couponProvider.expired == false) {
                          print('not expired');
                          //not expired,coupon is valid
                          setState(() {
                            _visible = true;
                          });
                          EasyLoading.dismiss();
                          return;
                        }
                        if (_couponProvider.expired == true) {
                          print('expired');
                          //expired,coupon is not valid
                          setState(() {
                            _visible = false;
                            _couponProvider.discountRate = 0;
                          });
                          EasyLoading.dismiss();
                          showDialog(
                              _couponController.text, context, 'Expired');
                          return;
                        }
                        EasyLoading.dismiss();
                        print('bos');
                      });
                    },
                    child: Text(
                      'Apply',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //active coupon card
          Visibility(
            visible: _visible,
            child: _couponProvider.document == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: DottedBorder(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.deepOrange.withOpacity(.4),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _couponProvider.document == null
                                          ? ''
                                          : _couponProvider.document
                                              .data()['title'],
                                      style: TextStyle(
                                          fontFamily: 'Lato-Regular.ttf'),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey[800],
                                  ),
                                  Text(
                                    _couponProvider.document == null
                                        ? ''
                                        : _couponProvider.document
                                            .data()['details'],
                                    style: TextStyle(
                                        fontFamily: 'Lato-Regular.ttf'),
                                  ),
                                  Text(
                                    _couponProvider.document == null
                                        ? ''
                                        : 'Tüm ürünlerde %${_couponProvider.document.data()['discountRate']} indirim',
                                    style: TextStyle(
                                        fontFamily: 'Lato-Regular.ttf'),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                            Positioned(
                              right: -5,
                              top: -10,
                              child: IconButton(
                                onPressed: () {
                                  _couponProvider.discountRate = 0;
                                  _visible = false;
                                  _couponController.clear();
                                },
                                icon: Icon(Icons.clear),
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
    );
  }

  showDialog(code, context, validity) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('APPLY COUPON'),
            content: Text(
                'This discount coupon $code you have entered is $validity.Please try with another code.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }
}
