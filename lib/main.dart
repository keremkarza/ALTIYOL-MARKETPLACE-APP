import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multivendor_app/providers/auth_provider.dart';
import 'package:multivendor_app/providers/cart_provider.dart';
import 'package:multivendor_app/providers/coupon_provider.dart';
import 'package:multivendor_app/providers/location_provider.dart';
import 'package:multivendor_app/providers/order_provider.dart';
import 'package:multivendor_app/screens/cart_screen.dart';
import 'package:multivendor_app/screens/navbars/profile_screen.dart';
import 'package:multivendor_app/screens/products/product_details_screen.dart';
import 'package:multivendor_app/screens/vendor_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/home_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/navbars/main_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/landing_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/login_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/map_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/onboard_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/register_screen.dart';
import 'file:///C:/Users/TULPAR/AndroidStudioProjects/multivendor_app/lib/screens/starter/welcome_screen.dart';

import 'providers/store_provider.dart';
import 'screens/navbars/my_orders_screen.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/profile_update_screen.dart';
import 'screens/starter/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.setMockInitialValues(({}));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CouponProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF008744),
        backgroundColor: Colors.blueGrey[900],
        indicatorColor: Colors.lightGreen[200],
        secondaryHeaderColor: Colors.black,
        fontFamily: 'Lato',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        OnBoardScreen.id: (context) => OnBoardScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        SplashScreen.id: (context) => SplashScreen(),
        MapScreen.id: (context) => MapScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        MyOrdersScreen.id: (context) => MyOrdersScreen(),
        LandingScreen.id: (context) => LandingScreen(),
        MainScreen.id: (context) => MainScreen(),
        VendorHomeScreen.id: (context) => VendorHomeScreen(),
        ProductListScreen.id: (context) => ProductListScreen(),
        ProductDetailsScreen.id: (context) => ProductDetailsScreen(),
        CartScreen.id: (context) => CartScreen(),
        UpdateProfileScreen.id: (context) => UpdateProfileScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}
