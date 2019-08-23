import 'package:contractor_search/utils/auth_status.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layouts/home_screen.dart';
import 'layouts/phone_auth_screen.dart';

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

  @override
  void initState() {
    checkAuthStatus();
    super.initState();
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
