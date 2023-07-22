import 'package:buy_sell_app/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'provider/providers.dart';
import 'utils/utils.dart';
import 'error.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for high importance notifications',
  importance: Importance.max,
  playSound: true,
);

String? token = '';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(_) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase App
  await Firebase.initializeApp();

  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  // Set preferred device orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Flutter Local Notifications Plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Set foreground notification presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppNavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SellerFormProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: const MyApp(),
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
  void initState() {
    super.initState();
    registerMessaging();
  }

  void updateToken(bool isAllowed) async {
    token = isAllowed ? await FirebaseMessaging.instance.getToken() : '';
  }

  void registerMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      updateToken(true);
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      updateToken(false);
      showSnackBar(
        content: 'You won\'t get important notifications.',
        color: redColor,
      );
    }

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      // Handle the initial notification message (if any)
      handleNotificationMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the incoming notification messages
      handleNotificationMessage(message);
    });
  }

  Future<void> handleNotificationMessage(RemoteMessage? message) async {
    if (message != null) {
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              playSound: true,
              importance: Importance.max,
              priority: Priority.high,
              color: greenColor,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BechDe',
      color: blueColor,
      themeMode: ThemeMode.light,
      theme: ThemeData(fontFamily: 'Rubik'),
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => const ErrorScreen(),
        );
      },
    );
  }
}
