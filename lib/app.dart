import 'package:contractor_search/layouts/tutorial_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_delegate.dart';
import 'package:contractor_search/utils/auth_status.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layouts/authentication_screen.dart';
import 'layouts/home_page.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if(deviceLocale!=null) {
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
                  ? HomePage(
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
          '/phoneAuthScreen': (BuildContext context) => AuthenticationScreen(showExpiredSessionMessage: false,),
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

    if(currentUser!=null){
      await FirebaseAuth.instance.signOut();
    }
  }
}
