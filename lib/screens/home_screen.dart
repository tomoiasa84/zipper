import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'contacts_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    Container(),
    ContactsScreen(),
    Container(),
    Container(),
    AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: _children[_currentIndex],
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
