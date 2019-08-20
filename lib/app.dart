import 'package:contractor_search/screens/home_screen.dart';
import 'package:contractor_search/screens/phone_auth_screen.dart';
import 'package:contractor_search/utils/auth_status.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  SharedPreferences preferences;

  String accessToken;
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  @override
  void initState() {
    _listenForPermissionStatus();
    checkAuthStatus();
    requestPermission(PermissionGroup.contacts);
    super.initState();
  }

  void _listenForPermissionStatus() {
    final Future<PermissionStatus> statusFuture =
    PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
      });
    });
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
    await PermissionHandler().requestPermissions(permissions);

    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[permission];
      if (_permissionStatus == PermissionStatus.granted) {
        Navigator.of(context).pushReplacementNamed('/contactspage');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        home: Builder(
          builder: (context) => authStatus == AuthStatus.LOGGED_IN
              ? HomePage()
              : PhoneAuthScreen(),
        ),
        routes: <String, WidgetBuilder>{
          '/phoneAuthScreen': (BuildContext context) => PhoneAuthScreen(),
          '/homepage': (BuildContext context) => HomePage(),
        });
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
  }
}
