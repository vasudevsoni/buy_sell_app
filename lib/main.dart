import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/screens/my_ads_screen.dart';
import 'package:buy_sell_app/screens/selling/congratulations_screen.dart';
import 'package:buy_sell_app/screens/selling/vehicle_ad_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'screens/landing_screen.dart';
import 'provider/product_provider.dart';
import 'provider/seller_form_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //   apiKey: "AIzaSyBV8-qmnmEAenGh1TgCR1QOrRNI2hJqdpQ",
      //   authDomain: "buy-sell-app-ff3ee.firebaseapp.com",
      //   projectId: "buy-sell-app-ff3ee",
      //   storageBucket: "buy-sell-app-ff3ee.appspot.com",
      //   messagingSenderId: "585586390479",
      //   appId: "1:585586390479:web:5ae73aaf46954de2b00eba",
      //   measurementId: "G-BBG34MXPLN",
      // ),
      );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SellerFormProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      // home: const LandingScreen(),
      // home: MyAdsScreen(),
      home: MainScreen(),
      // home: CongratulationsScreen(),
      // home: const VehicleAdPostScreen(subCatName: 'test'),
    );
  }
}
