import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/store_provider.dart';
import 'package:multivendor_app/services/product_services.dart';
import 'package:provider/provider.dart';

class ProductFilterWidget extends StatefulWidget {
  @override
  _ProductFilterWidgetState createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  List _subCategoryList = [];
  ProductServices _services = ProductServices();
  bool _isActive = false;

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);
    FirebaseFirestore.instance
        .collection('products')
        .where('category.mainCategory',
            isEqualTo: _store.selectedProductCategory)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _subCategoryList.add(doc['category']['subCategory']);
        });
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _storeData = Provider.of<StoreProvider>(context);

    return FutureBuilder<DocumentSnapshot>(
      future: _services.category.doc(_storeData.selectedProductCategory).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (!snapshot.hasData) {
          return Container();
        }

        Map<String, dynamic> data = snapshot.data.data();
        var dataInside = data['subCategory'];

        //print(data);
        //print(data['subCategory']);
        print('length : ${dataInside.length}');
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(.8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(.9),
            ),
          ),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 10),
                ActionChip(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 4,
                  label: Text(
                    'All ${_storeData.selectedProductCategory}',
                    style: TextStyle(
                        color: _isActive ? Colors.white : Colors.black54),
                  ),
                  onPressed: () {
                    _storeData.getSelectedSubCategory(null);
                  },
                  backgroundColor: _isActive ? Colors.green : Colors.white,
                ),
                ListView.builder(
                  itemCount: dataInside.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: ScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    print(index);
                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: _subCategoryList
                              .contains(data['subCategory'][index]['name'])
                          ? ActionChip(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 4,
                              label: Text(
                                '${data['subCategory'][index]['name']}',
                                style: TextStyle(
                                    color: _isActive
                                        ? Colors.white
                                        : Colors.black54),
                              ),
                              onPressed: () {
                                //_isActive = true;
                                _storeData.getSelectedSubCategory(
                                    data['subCategory'][index]['name']);
                              },
                              backgroundColor:
                                  _isActive ? Colors.green : Colors.white,
                            )
                          : Container(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
