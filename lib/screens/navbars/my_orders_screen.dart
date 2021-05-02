import 'package:auto_size_text/auto_size_text.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multivendor_app/providers/order_provider.dart';
import 'package:multivendor_app/services/order_services.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  static const String id = 'orders-screen';

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int tag = 0;
  List<String> options = [
    'Tümü',
    'Sipariş Verildi',
    'Kabul Edildi',
    'Hazırlanıyor',
    'Yolda',
    'Teslim Edildi',
  ];
  List<String> optionsForChange = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked Up',
    'On the way',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    OrderServices _orderServices = OrderServices();
    OrderProvider _orderProvider = Provider.of<OrderProvider>(context);
    User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Siparişlerim',
          style: TextStyle(color: Colors.white, fontFamily: 'Lato-Regular.ttf'),
        ),
        centerTitle: true,
        actions: [
          Visibility(
            visible: false,
            child: IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.search, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle:
                  C2ChoiceStyle(borderRadius: BorderRadius.circular(3)),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status = null;
                  });
                }
                setState(() {
                  tag = val;

                  if (tag > 0) {
                    _orderProvider.filterOrder(optionsForChange[val]);
                  }
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                style: (i, v) => C2ChoiceStyle(
                    labelStyle: TextStyle(fontFamily: 'Lato-Regular.ttf')),
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('userId', isEqualTo: user.uid)
                  .where('seller.orderStatus',
                      isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Birseyler yanlis gitti.');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data.size == 0) {
                  //TODO: No orders screen will be seen here
                  return Center(
                      child: Text(
                    tag > 0
                        ? '${options[tag]} kısmında siparis yok.'
                        : 'Siparis Yok. Alışverişe devam edin.',
                    style: TextStyle(fontFamily: 'Lato-Regular.ttf'),
                  ));
                }

                return Expanded(
                  child: new ListView(
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return new Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                _orderServices.statusString(document),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _orderServices.statusColor(document),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lato-Regular.ttf',
                                ),
                              ),
                              subtitle: Text(
                                'Tarih :  ${DateFormat.yMMMd().format(DateTime.parse(document.data()['seller']['timeStamp']))}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 15,
                                child: _orderServices.statusIcon(document),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AutoSizeText(
                                    'Ödeme Tipi : ${document.data()['cod'] == 0 ? 'Online' : document.data()['cod'] == 2 ? 'Kapıda Kartla' : 'Kapıda Nakit'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lato-Regular.ttf',
                                    ),
                                  ),
                                  Text(
                                    'Miktar : ${document.data()['total']} TL',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lato-Regular.ttf',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            document.data()['deliveryBoy'] == null
                                ? Container()
                                : document
                                            .data()['deliveryBoy']['name']
                                            .length >
                                        2
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: ListTile(
                                            tileColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(.2),
                                            title: Text(
                                              document.data()['deliveryBoy']
                                                  ['name'],
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              _orderServices
                                                  .statusComment(document),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontFamily:
                                                      'Lato-Regular.ttf'),
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              child: document.data()[
                                                              'deliveryBoy']
                                                          ['image'] ==
                                                      null
                                                  ? Image.network(
                                                      'https://firebasestorage.googleapis.com/v0/b/multivendor-app-9b552.appspot.com/o/assets%2FALTIYOL_LOGO.png?alt=media&token=579e324c-d996-43be-8264-157b2ea04c2f')
                                                  : Image.network(
                                                      document.data()[
                                                              'deliveryBoy']
                                                          ['image'],
                                                      height: 24,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                            ExpansionTile(
                              title: Text(
                                'Sipariş Detayları',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontFamily: 'Lato-Regular.ttf',
                                ),
                              ),
                              subtitle: Text(
                                'Sipariş Detaylarını Görüntüle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontFamily: 'Lato-Regular.ttf',
                                ),
                              ),
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: ClipOval(
                                          child: Image.network(
                                              document.data()['products'][index]
                                                  ['productImage']),
                                        ),
                                      ),
                                      title: Text(
                                        document.data()['products'][index]
                                            ['productName'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      subtitle: Text(
                                        '${document.data()['products'][index]['qty']} x ${document.data()['products'][index]['price'].toStringAsFixed(2)} TL = ${document.data()['products'][index]['total'].toStringAsFixed(2)} TL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: document.data()['products'].length,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, top: 8, bottom: 8),
                                  child: Card(
                                    elevation: 4,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Satıcı : ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  fontFamily:
                                                      'Lato-Regular.ttf',
                                                ),
                                              ),
                                              Text(
                                                document.data()['seller']
                                                    ['shopName'],
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily:
                                                      'Lato-Regular.ttf',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'İndirim : ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'Lato-Regular.ttf',
                                                    ),
                                                  ),
                                                  Text(
                                                    document.data()['discount'],
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontFamily:
                                                          'Lato-Regular.ttf',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Text(
                                                    'İndirim Kodu : ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      fontFamily:
                                                          'Lato-Regular.ttf',
                                                    ),
                                                  ),
                                                  Text(
                                                    document.data()[
                                                                'discountCode'] ==
                                                            null
                                                        ? 'YOK'
                                                        : document.data()[
                                                            'discountCode'],
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'Teslimat Ücreti : ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  fontFamily:
                                                      'Lato-Regular.ttf',
                                                ),
                                              ),
                                              Text(
                                                document
                                                    .data()['deliveryFee']
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 3, color: Colors.grey),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
