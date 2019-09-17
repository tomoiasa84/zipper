import 'dart:ui';

import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/utils/tab_navigation_utils.dart';
import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'users_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool blurred = false;

  final _tabNavigator = GlobalKey<TabNavigatorState>();
  final _tab1 = GlobalKey<NavigatorState>();
  final _tab2 = GlobalKey<NavigatorState>();
  final _tab3 = GlobalKey<NavigatorState>();
  final _tab4 = GlobalKey<NavigatorState>();
  final _tab5 = GlobalKey<NavigatorState>();

  var _tabSelectedIndex = 0;
  var _tabPopStack = false;

  void _setIndex(index) {
    setState(() {
      _tabPopStack = _tabSelectedIndex == index;
      _tabSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        WillPopScope(
          onWillPop: () async => await _tabNavigator.currentState.maybePop(),
          child: Scaffold(
              body: TabNavigator(
                key: _tabNavigator,
                tabs: <TabItem>[
                  TabItem(_tab1, Container()),
                  TabItem(_tab2, UsersScreen()),
                  TabItem(_tab3, Container()),
                  TabItem(_tab4, Container()),
                  TabItem(
                      _tab5,
                      AccountScreen(
                        onChanged: _onBlurredChanged,
                      )),
                ],
                selectedIndex: _tabSelectedIndex,
                popStack: _tabPopStack,
              ),
              bottomNavigationBar: _buildBottomNavigationBar()),
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

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _tabSelectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _setIndex,
      items: [
        BottomNavigationBarItem(
            icon: new Icon(Icons.home,
                color:
                    (_tabSelectedIndex == 0) ? Colors.black : ColorUtils.gray),
            title: Container(
              height: 0.0,
            )),
        BottomNavigationBarItem(
            icon: new Icon(Icons.people,
                color:
                    (_tabSelectedIndex == 1) ? Colors.black : ColorUtils.gray),
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
            icon: (_tabSelectedIndex == 3)
                ? Image.asset("assets/images/ic_inbox_black.png")
                : Image.asset("assets/images/ic_inbox_gray.png"),
            title: Container(
              height: 0.0,
            )),
        BottomNavigationBarItem(
            icon: new Icon(Icons.person,
                color:
                    (_tabSelectedIndex == 4) ? Colors.black : ColorUtils.gray),
            title: Container(
              height: 0.0,
            )),
      ],
    );
  }

  void _onBlurredChanged(bool value) {
    setState(() {
      blurred = value;
    });
  }
}
