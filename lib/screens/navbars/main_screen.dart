import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multivendor_app/providers/cart_provider.dart';
import 'package:multivendor_app/widgets/cart/cart_notification.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/favourites_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/my_orders_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/profile_screen.dart';

import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main-screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isSame = false;
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  // CollectionReference pushtokens =
  //     FirebaseFirestore.instance.collection('pushtokens');
  // final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    // _messaging.getToken().then((token) {
    //   FirebaseFirestore.instance
    //       .collection('pushtokens')
    //       .get()
    //       .then((QuerySnapshot querySnapshot) {
    //     querySnapshot.docs.forEach((doc) {
    //       if (doc['devtoken'] == token) {
    //         isSame = true;
    //         print("aynı");
    //       } else {
    //         print("farklı");
    //         if (!isSame) {
    //           print("hiç aynı olmamış");
    //           pushtokens.add({
    //             "devtoken": token,
    //           });
    //         }
    //       }
    //     });
    //   });
    //   print(token);
    // });
  }

  // @override
  // void didChangeDependencies() {
  //   setState(() {
  //     print('didchangeinmain');
  //   });
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    List<Widget> _buildScreens() {
      return [
        HomeScreen(),
        FavouritesScreen(),
        MyOrdersScreen(),
        ProfileScreen(),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.home),
          title: ("Anasayfa"),
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          activeColorPrimary: Theme.of(context).primaryColor,
          activeColorSecondary: Colors.white,
          inactiveColorPrimary: Theme.of(context).primaryColor,
          //inactiveColorSecondary: Colors.white
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.square_favorites_alt),
          title: ("Takip Ettiklerim"),
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          activeColorPrimary: Theme.of(context).primaryColor,
          activeColorSecondary: Colors.white,
          inactiveColorPrimary: Theme.of(context).primaryColor,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.bag),
          title: ("Siparislerim"),
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          activeColorPrimary: Theme.of(context).primaryColor,
          activeColorSecondary: Colors.white,
          inactiveColorPrimary: Theme.of(context).primaryColor,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.profile_circled),
          title: ("Hesabım"),
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          activeColorPrimary: Theme.of(context).primaryColor,
          activeColorSecondary: Colors.white,
          inactiveColorPrimary: Theme.of(context).primaryColor,
          //inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    return Scaffold(
      //?? yes
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: Consumer<CartProvider>(
          //child: CartNotification(),
          builder: (context, data, child) {
            return CartNotification();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PersistentTabView(
        context,
        controller: _controller,
        navBarHeight: 56,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears.
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(2),
          colorBehindNavBar:
              Theme.of(context).primaryColor, //CupertinoColors.systemGrey,
          border: Border.all(),
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style10, // Choose the nav bar style with this property.
      ),
    );
  }
}
