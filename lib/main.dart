import 'package:buy_sell_app/screens/chats/conversation_screen.dart';
import 'package:buy_sell_app/screens/main_screen.dart';
import 'package:buy_sell_app/screens/my_listings_screen.dart';
import 'package:buy_sell_app/screens/my_profile_screen.dart';
import 'package:buy_sell_app/screens/update_profile_screen.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'provider/seller_form_provider.dart';
import 'screens/selling/vehicle_ad_post_screen.dart';

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
      onGenerateRoute: (settings) => generateRoute(settings),
      // home: const LandingScreen(),
      // home: Scaffold(
      //   body: DoubleBackToCloseApp(
      //     snackBar: SnackBar(
      //       content: Text(
      //         'Press back again to leave',
      //         textAlign: TextAlign.center,
      //         style: GoogleFonts.poppins(
      //           fontSize: 15,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //       elevation: 0,
      //       backgroundColor: redColor,
      //       dismissDirection: DismissDirection.horizontal,
      //       duration: const Duration(seconds: 2),
      //       behavior: SnackBarBehavior.floating,
      //     ),
      //     child: const MainScreen(),
      //   ),
      // ),
      home: MainScreen(),
    );
  }
}
