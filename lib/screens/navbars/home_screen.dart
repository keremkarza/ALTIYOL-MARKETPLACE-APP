import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/widgets/image_slider.dart';
import 'package:multivendor_app/widgets/my_appbar.dart';
import 'package:multivendor_app/widgets/near_by_stores.dart';
import 'package:multivendor_app/widgets/top_picked_stores.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tag = 0;
  List<String> options = [
    'Tümü',
    'Yemek',
    'Market',
    'Giyim',
    'Kasap',
    'Eczane',
    'Diger',
  ];

  var status;

  @override
  void didChangeDependencies() {
    // setState(() {
    //   print('didchangeinhome');
    // });
    super.didChangeDependencies();
  }
  //
  // @override
  // void initState() {
  //   _filterInStart();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    //final auth = Provider.of<AuthProvider>(context);
    //final _storeProvider = Provider.of<StoreProvider>(context);
    print('home build');
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            MySliverAppBar(),
          ];
        },
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            ImageSlider(),
            Material(
              elevation: 20,
              shadowColor: Colors.white70,
              child: Container(
                child: TopPickedStores(),
              ),
            ),
            Visibility(
              visible: false,
              child: Container(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: ChipsChoice<int>.single(
                  choiceStyle:
                      C2ChoiceStyle(borderRadius: BorderRadius.circular(3)),
                  value: tag,
                  onChanged: (val) {
                    // if (val == 0) {
                    //   setState(() {
                    //     _storeProvider.status = null;
                    //   });
                    // }
                    // setState(() {
                    //   tag = val;
                    //
                    //   if (tag > 0) {
                    //     _storeProvider.filterOrder(options[val], true);
                    //   }
                    // });
                    // print('after change : ${_storeProvider.status}');
                  },
                  choiceItems: C2Choice.listFrom<int, String>(
                    // i was trying here,then i did it in nearby file
                    source: options,
                    value: (i, v) => i,
                    label: (i, v) => v,
                  ),
                ),
              ),
            ),
            NearByStores(statusFromHome: status),
          ],
        ),
      ),
    );
  }

  // _filterInStart() async {
  //   await Future.delayed(Duration(milliseconds: 50));
  //   final _store = Provider.of<StoreProvider>(context, listen: false);
  //   SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
  //         print('denemefilter : ${_store.status}');
  //         _store.filterOrder(
  //             _store.status == null ? options[tag] : _store.status, true);
  //       }));
  //
  //   //do something
  // }
}
