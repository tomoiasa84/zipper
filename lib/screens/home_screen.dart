import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Container(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
}
