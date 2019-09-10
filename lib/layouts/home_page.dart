import 'dart:ui';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/bloc/home_bloc.dart';
import 'package:contractor_search/layouts/conversations_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'account_screen.dart';
import 'contacts_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc;
  Iterable<Contact> _contacts;

  bool blurred = false;

  @override
  void didChangeDependencies() {
    _homeBloc = HomeBloc();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (this.mounted) {
      _fetchContacts();
    }
    super.initState();
  }

  void _fetchContacts() {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      if (status == PermissionStatus.granted)
        _homeBloc.getContacts().then((values) {
          setState(() {
            _contacts = values;
          });
        });
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
          body: StreamBuilder<NavBarItem>(
            stream: _homeBloc.itemStream,
            initialData: _homeBloc.defaultItem,
            builder:
                (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
              switch (snapshot.data) {
                case NavBarItem.HOME:
                  return Container();
                case NavBarItem.CONTACTS:
                  return ContactsScreen(
                    contacts: _contacts,
                  );
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
      onTap: _homeBloc.pickItem,
      selectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      currentIndex: snapshot.data.index,
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

  void _onBlurredChanged(bool value) {
    setState(() {
      blurred = value;
    });
  }
}
