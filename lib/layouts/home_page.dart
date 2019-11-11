import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:contractor_search/bloc/home_bloc.dart';
import 'package:contractor_search/layouts/card_details_screen.dart';
import 'package:contractor_search/layouts/conversations_screen.dart';
import 'package:contractor_search/layouts/home_content_screen.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PushNotification.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'account_screen.dart';
import 'add_card_screen.dart';
import 'chat_screen.dart';
import 'users_screen.dart';

class HomePage extends StatefulWidget {
  final bool syncContactsFlagRequired;

  HomePage({Key key, this.syncContactsFlagRequired}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool blurred = false;
  HomeBloc _homeBloc = HomeBloc();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  UserMessage _message;
  var _notificationsChannel =
      BasicMessageChannel<String>('iosNotificationTapped', StringCodec());
  var _currentUserChannel =
      BasicMessageChannel<String>('currentUserId', StringCodec());
  var _recommendationChannel =
      BasicMessageChannel<String>('iosRecommendationTapped', StringCodec());
  User _user;

  StreamSubscription<ConnectivityResult> subscription;

  bool connected = false;

  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        setState(() {
          connected = true;
        });
        _homeBloc = HomeBloc();
        if (widget.syncContactsFlagRequired) {
          _saveSyncContactsFlag(true);
        }
        _homeBloc.getCurrentUser().then((result) {
          if (result.errors == null) {
            _user = User.fromJson(result.data['get_user']);
          }
        });
        _initFirebaseClientMessaging();
        _initLocalNotifications();
        _homeBloc.updateDeviceToken();
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
      } else {
        setState(() {
          connected = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
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
    if (Platform.isIOS) iosPermission();

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
    return Stack(
      children: <Widget>[
        Scaffold(
          bottomNavigationBar: StreamBuilder<NavBarItem>(
            stream: _homeBloc.itemStream,
            initialData: _homeBloc.defaultItem,
            builder:
                (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
              return _buildBottomNavigationBar(snapshot);
            },
          ),
          body: StreamBuilder(
            stream: Connectivity().onConnectivityChanged,
            builder: (BuildContext context,
                AsyncSnapshot<ConnectivityResult> snapShot) {
              if (snapShot.hasData &&
                  snapShot.data != ConnectivityResult.none) {
                connected = snapShot.data != ConnectivityResult.none;
              }
              return StreamBuilder<NavBarItem>(
                stream: _homeBloc.itemStream,
                initialData: _homeBloc.defaultItem,
                builder:
                    (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
                  switch (snapshot.data) {
                    case NavBarItem.HOME:
                      return HomeContentScreen(
                        connected: connected,
                        user: _user,
                        onUserUpdated: (cardsConnections, cards) {
                          if (_user != null) {
                            _user.cardsConnections = cardsConnections;
                            _user.cards = cards;
                          }
                        },
                      );
                    case NavBarItem.CONTACTS:
                      return UsersScreen(
                        connected: connected,
                        user: _user,
                        updateCurrentUser: (connections) {
                          if (_user != null && _user.connections != null) {
                            _user.connections = connections;
                          }
                        },
                      );
                    case NavBarItem.PLUS:
                      return Container();
                    case NavBarItem.INBOX:
                      return ConversationsScreen(
                        connected: connected,
                      );
                    case NavBarItem.ACCOUNT:
                      return AccountScreen(
                        connected: connected,
                        user: _user,
                        onChanged: _onBlurredChanged,
                        isStartedFromHomeScreen: true,
                        onUserChanged: (newUser) {
                          if (_user != null && newUser != null)
                            _user.name = newUser.name;
                          _user.phoneNumber = newUser.phoneNumber;
                          _user.description = newUser.description;
                          _user.tags = newUser.tags;
                          _user.cards = newUser.cards;
                          _user.profilePicUrl = newUser.profilePicUrl;
                          _user.reviews = newUser.reviews;
                        },
                      );
                    default:
                      return Container();
                  }
                },
              );
//              else {
//                return Center(
//                  child: Text(Localization.of(context).getString("error")),
//                );
//              }
            },
          ),
        ),
        (blurred)
            ? new Container(
                decoration:
                    new BoxDecoration(color: Colors.black.withOpacity(0.6)),
              )
            : Container(),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
      AsyncSnapshot<NavBarItem> snapshot) {
    return BottomNavigationBar(
      currentIndex: snapshot.data.index,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 2) {
          if (connected) {
            _goToAddCardScreen();
            _homeBloc.pickItem(index);
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                title: "",
                description:
                    Localization.of(context).getString("noInternetConnection"),
                buttonText: Localization.of(context).getString("ok"),
              ),
            );
          }
        } else {
          _homeBloc.pickItem(index);
        }
      },
      selectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
            icon: new Icon(Icons.home,
                color: (snapshot.data.index == 0)
                    ? Colors.black
                    : ColorUtils.gray),
            title: Container(
              height: 0.0,
            )),
        BottomNavigationBarItem(
            icon: new Icon(Icons.people,
                color: (snapshot.data.index == 1)
                    ? Colors.black
                    : ColorUtils.gray),
            title: Container(
              height: 0.0,
            )),
        BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/ic_plus_accent_background.png",
            ),
            title: Container(
              height: 0.0,
            )),
        BottomNavigationBarItem(
            icon: (snapshot.data.index == 3)
                ? Image.asset("assets/images/ic_inbox_black.png")
                : Image.asset("assets/images/ic_inbox_gray.png"),
            title: Container(
              height: 0.0,
            )),
        BottomNavigationBarItem(
            icon: new Icon(Icons.person,
                color: (snapshot.data.index == 4)
                    ? Colors.black
                    : ColorUtils.gray),
            title: Container(
              height: 0.0,
            )),
      ],
    );
  }

  Future<void> _goToAddCardScreen() async {
    var result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => AddCardScreen(
          connected: connected,
              user: _user,
              updateUsersCards: (userCards) {
                if (_user != null) {
                  _user.cards = userCards;
                }
              },
            )));
    _homeBloc.pickItem(0);
    if (result != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: Localization.of(context).getString("success"),
          description: Localization.of(context)
              .getString("yourPostHasBeenSuccessfullyAdded"),
          buttonText: Localization.of(context).getString("ok"),
        ),
      );
    }
  }

  void _onBlurredChanged(bool value) {
    setState(() {
      blurred = value;
    });
  }

  Future _saveSyncContactsFlag(bool syncValue) async {
    await SharedPreferencesHelper.saveSyncContactsFlag(true);
  }
}
