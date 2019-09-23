import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_delegate.dart';
import 'package:contractor_search/utils/auth_status.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layouts/home_page.dart';
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
  bool _syncContactsFlag = false;

  @override
  void initState() {
    checkAuthStatus();
    _getSyncContactsFlag();
    super.initState();
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
              ? (_syncContactsFlag ? HomePage(syncContactsFlagRequired: false,) : TutorialScreen())
              : PhoneAuthScreen(),
        ),
        routes: <String, WidgetBuilder>{
          '/phoneAuthScreen': (BuildContext context) => PhoneAuthScreen(),
          '/homepage': (BuildContext context) => HomePage(syncContactsFlagRequired: false,),
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
