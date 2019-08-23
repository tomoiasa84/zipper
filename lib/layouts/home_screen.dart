import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contacts_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Iterable<Contact> _contacts;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  getContacts() async {
    return ContactsService.getContacts();
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
        getContacts().then((values) {
          setState(() {
            _contacts = values;
          });
        });
      }
    });
  }

  @override
  void initState() {
    _listenForPermissionStatus();
    requestPermission(PermissionGroup.contacts);
    super.initState();
  }

  Widget getPage(int index) {
    if (index == 1) {
      return ContactsScreen(contacts: _contacts);
    }
    // A fallback, in this case just PageOne
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: getPage(_currentIndex),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.home,
            color: Colors.black,
          ),
          title: new Text(
            'Home',
            style: TextStyle(color: Colors.black),
          ),
        ),
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.contacts,
            color: Colors.black,
          ),
          title: new Text(
            'Contacts',
            style: TextStyle(color: Colors.black),
          ),
        ),
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.plus_one,
            color: Colors.black,
          ),
          title: new Text(
            'Plus',
            style: TextStyle(color: Colors.black),
          ),
        ),
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.inbox,
            color: Colors.black,
          ),
          title: new Text(
            'Inbox',
            style: TextStyle(color: Colors.black),
          ),
        ),
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.account_box,
            color: Colors.black,
          ),
          title: new Text(
            'Account',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
