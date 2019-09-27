import 'dart:ui';

import 'package:contractor_search/bloc/home_bloc.dart';
import 'package:contractor_search/layouts/conversations_screen.dart';
import 'package:contractor_search/layouts/home_content_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'add_post_screen.dart';
import 'users_screen.dart';

class HomePage extends StatefulWidget {
  final bool syncContactsFlagRequired;

  HomePage({Key key, this.syncContactsFlagRequired}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool blurred = false;
  HomeBloc _homeBloc;

  @override
  void initState() {
    _homeBloc = HomeBloc();
    if (widget.syncContactsFlagRequired) {
      _saveSyncContactsFlag(true);
    }
    super.initState();
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
          body: StreamBuilder<NavBarItem>(
            stream: _homeBloc.itemStream,
            initialData: _homeBloc.defaultItem,
            builder:
                (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
              switch (snapshot.data) {
                case NavBarItem.HOME:
                  return HomeContentScreen();
                case NavBarItem.CONTACTS:
                  return UsersScreen();
                case NavBarItem.PLUS:
                  return Container();
                case NavBarItem.INBOX:
                  return ConversationsScreen();
                case NavBarItem.ACCOUNT:
                  return AccountScreen(
                    onChanged: _onBlurredChanged,
                  );
                default:
                  return Container();
              }
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
          _homeBloc.pickItem(0);
          _goToAddPostScreen();
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

  Future<void> _goToAddPostScreen() async {
    var result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => AddPostScreen()));
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
