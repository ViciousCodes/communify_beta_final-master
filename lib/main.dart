import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bottom_nav.dart';
import 'package:communify_beta_final/firebase_options.dart';
import 'package:communify_beta_final/screens/login_screen.dart';
import 'package:communify_beta_final/screens/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'bottom_nav_club.dart';
import 'dart:io';

Color primary = const Color(0xFF09152D);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const bool useEmulator = false;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  print("Handling a background message: ${message.messageId}");

  // Here you could also handle friend request logic depending on your data structure
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, name: 'commUnify');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? initialRoutePayload;

  MyApp({required this.navigatorKey, Key? key})
      : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(),
        super(key: key) {
    _configureLocalNotifications();
    _configureFirebaseMessaging();
  }
  Future<void> _configureLocalNotifications() async {
    var androidInitializationSettings = const AndroidInitializationSettings('mipmap/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: iosInitialization);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification);;
    final NotificationAppLaunchDetails? launchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      initialRoutePayload = launchDetails?.notificationResponse?.payload;
    }
  }


  void _configureFirebaseMessaging() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'token': newToken,
        });
      }
    });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');

          var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
          );

          var iosPlatformChannelSpecifics = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
            subtitle: 'Notification Subtitle',
            threadIdentifier: 'thread_id',
          );

          var platformChannelSpecifics = NotificationDetails(
              android: androidPlatformChannelSpecifics,
              iOS: iosPlatformChannelSpecifics
          );

          flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title,
            message.notification!.body,
            platformChannelSpecifics,
            payload: message.data['route'],
          );
        }
      });
  }
  Future onDidReceiveLocalNotification(NotificationResponse response) async {
    final route = response.payload;
    if (route == 'FRIEND_REQUEST_SCREEN') {
      initialRoutePayload = route;
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseStorage storage = FirebaseStorage.instance;
    if (useEmulator) {
      db.useFirestoreEmulator(host, 8080);
      auth.useAuthEmulator(host, 9099);
      storage.useStorageEmulator(host, 9199);
      db.settings = const Settings(
        persistenceEnabled: false,
      );
    }
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        return CupertinoApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'commUnify',
          theme: CupertinoThemeData(
            primaryColor: primary,
            barBackgroundColor: CupertinoColors.white,
            scaffoldBackgroundColor: CupertinoColors.white,
            textTheme: CupertinoTextThemeData(
                primaryColor: primary,
            ),
            brightness: Brightness.light,
          ),
          home: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent, // Set status bar color to black
              statusBarIconBrightness: Brightness.dark, // Set status bar icons to be black
            ),
            child: _buildHome(snapshot),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
        );
      },
    );
  }

  Widget _buildHome(AsyncSnapshot<SharedPreferences> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      final isLoggedIn = snapshot.data?.getBool('isLoggedIn') ?? false;
      final isClub = snapshot.data?.getBool('isClub') ?? false;

      if (initialRoutePayload == 'FRIEND_REQUEST_SCREEN') {
        return const NotificationsScreen();
      } else if (isLoggedIn && isClub) {
        return const BottomNavClub();
      } else if (isLoggedIn && !isClub) {
        return const BottomNav();
      } else {
        return const LoginScreen();
      }
    } else {
      // Show a loading spinner while waiting for SharedPreferences
      return const CupertinoActivityIndicator();
    }
  }
}