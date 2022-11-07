import 'package:buy_sell_app/provider/location_provider.dart';
import 'package:buy_sell_app/auth/screens/landing_screen.dart';
import 'package:buy_sell_app/provider/main_provider.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'provider/seller_form_provider.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notifications',
//   description: 'This channel is used for important notifications.',
//   importance: Importance.high,
//   playSound: true,
// );

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A message just showed up : ${message.messageId}');
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MainProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SellerFormProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: const MyApp(),
      // DevicePreview(
      //   builder: (context) {
      //     return const MyApp();
      //   },
      // ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => generateRoute(settings),
      home: const Scaffold(
        backgroundColor: whiteColor,
        body: LandingScreen(),
      ),
    );
  }
}
