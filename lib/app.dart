import 'dart:io';

import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/models/PushNotification.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_delegate.dart';
import 'package:contractor_search/utils/auth_status.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layouts/home_page.dart';
import 'layouts/phone_auth_screen.dart';
import 'models/UserMessage.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  SharedPreferences preferences;
  String accessToken;
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool _syncContactsFlag = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    checkAuthStatus();
    _getSyncContactsFlag();
    _initFirebaseClientMessaging();
    _initLocalNotifications();
    super.initState();
  }

  void _initLocalNotifications() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future _filterNotifications(Map<String, dynamic> notification) async {
    SharedPreferencesHelper.getCurrentUserId().then((currentUserId) {
      var messageData = new Map<String, dynamic>.from(notification['data']);
      UserMessage message = UserMessage.fromJson(messageData);

      if (message.messageAuthor != currentUserId) {
        var notificationMap =
            Map<String, dynamic>.from(notification['notification']);
        PushNotification pushNotification =
            PushNotification.fromJson(notificationMap);
        _showNotification(pushNotification);
      }
    });
  }

  Future _showNotification(PushNotification pushNotification) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1', 'General', 'Basic notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      pushNotification.title,
      pushNotification.body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  void _initFirebaseClientMessaging() {
    if (Platform.isIOS) iosPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        _filterNotifications(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          const LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('ro', ''),
        ],
        title: 'Flutter Demo',
        theme: ThemeData(primaryColor: ColorUtils.white, fontFamily: "Arial"),
        home: Builder(
          builder: (context) => authStatus == AuthStatus.LOGGED_IN
              ? (_syncContactsFlag
                  ? HomePage(
                      syncContactsFlagRequired: false,
                    )
                  : TutorialScreen())
              : PhoneAuthScreen(),
        ),
        routes: <String, WidgetBuilder>{
          '/phoneAuthScreen': (BuildContext context) => PhoneAuthScreen(),
          '/homepage': (BuildContext context) => HomePage(
                syncContactsFlagRequired: false,
              ),
        });
  }

  _getSyncContactsFlag() async {
    _syncContactsFlag = await SharedPreferencesHelper.getSyncContactsFlag();
  }

  Future checkAuthStatus() async {
    var accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    } else {
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    }
    print("ACCESS TOKEN: $accessToken");
  }
}
