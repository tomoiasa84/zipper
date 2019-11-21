import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_delegate.dart';
import 'package:contractor_search/utils/auth_status.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layouts/authentication_screen.dart';
import 'layouts/card_details_screen.dart';
import 'layouts/chat_screen.dart';
import 'layouts/tabs_container_screen.dart';
import 'models/PushNotification.dart';
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
  var _notificationsChannel =
      BasicMessageChannel<String>('iosNotificationTapped', StringCodec());
  var _currentUserChannel =
      BasicMessageChannel<String>('currentUserId', StringCodec());
  var _recommendationChannel =
      BasicMessageChannel<String>('iosRecommendationTapped', StringCodec());
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  UserMessage _message;

  @override
  void initState() {
    _notificationsChannel.setMessageHandler((String message) async {
      print('Received: $message');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(conversationId: message)),
          ModalRoute.withName("/"));
      return '';
    });
    _recommendationChannel.setMessageHandler((String message) async {
      print('Received: $message');
      _goToCardDetailsScreen(int.parse(message));
      return '';
    });
    SharedPreferencesHelper.getCurrentUserId().then((currentUserId) {
      _currentUserChannel.send(currentUserId);
      print('USER SENT');
    });
    _initFirebaseClientMessaging();
    _initLocalNotifications();
    checkAuthStatus();
    _getSyncContactsFlag();
    debugPrint('DART INITIALIZED');
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
      _message = UserMessage.fromJson(messageData);

      if (_message.messageAuthor != currentUserId) {
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
    print('Notification tapped');

    if (_message.cardId != null) {
      _goToCardDetailsScreen(_message.cardId);
    } else {
      _goToChatScreen();
    }
  }

  void _goToCardDetailsScreen(int cardId) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => CardDetailsScreen(cardId: cardId)),
        ModalRoute.withName("/"));
  }

  void _goToChatScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(conversationId: _message.channelId)),
        ModalRoute.withName("/"));
  }

  void _initFirebaseClientMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        _filterNotifications(message);
      },
      onResume: (Map<String, dynamic> message) async {
        var messageData = new Map<String, dynamic>.from(message['data']);
        _message = UserMessage.fromJson(messageData);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(conversationId: _message.channelId)),
            ModalRoute.withName("/"));
      },
      onLaunch: (Map<String, dynamic> message) async {
        var messageData = new Map<String, dynamic>.from(message['data']);
        _message = UserMessage.fromJson(messageData);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(conversationId: _message.channelId)),
            ModalRoute.withName("/"));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (deviceLocale != null) {
            for (var supportedLocale in supportedLocales) {
              if (deviceLocale.languageCode == supportedLocale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return supportedLocales.elementAt(0);
        },
        localizationsDelegates: [
          const LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('ro', ''),
        ],
        navigatorKey: GlobalVariable.navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(primaryColor: ColorUtils.white, fontFamily: "Arial"),
        home: Builder(
          builder: (context) => authStatus == AuthStatus.LOGGED_IN
              ? (_syncContactsFlag
                  ? TabsContainerScreen(
                      syncContactsFlagRequired: false,
                    )
                  : TutorialScreen())
              : (authStatus == AuthStatus.NOT_LOGGED_IN
                  ? AuthenticationScreen(showExpiredSessionMessage: false)
                  : Container(
                      color: ColorUtils.white,
                    )),
        ),
        routes: <String, WidgetBuilder>{
          '/phoneAuthScreen': (BuildContext context) => AuthenticationScreen(
                showExpiredSessionMessage: false,
              ),
          '/homepage': (BuildContext context) => TabsContainerScreen(
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
      checkFirebaseUserAuthStatus();
      setState(() {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      });
    } else {
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    }
    print("ACCESS TOKEN: $accessToken");
  }

  void checkFirebaseUserAuthStatus() async {
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

    if (currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }
}
