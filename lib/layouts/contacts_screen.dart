import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/bloc/contacts_bloc.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  final Iterable<Contact> contacts;

  ContactsScreen({Key key, this.contacts}) : super(key: key);

  @override
  ContactsScreenState createState() {
    return ContactsScreenState();
  }
}

class ContactsScreenState extends State<ContactsScreen> {
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  ContactsBloc _contactsBloc;

  @override
  void didChangeDependencies() {
    _contactsBloc = ContactsBloc();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _listenForPermissionStatus();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              _buildTabBar(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Strings.contacts,
        style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Column _buildTabBar() {
    return Column(
      children: <Widget>[
        new TabBar(
          labelStyle:
              TextStyle(fontFamily: "Arial", fontWeight: FontWeight.bold),
          isScrollable: true,
          labelColor: ColorUtils.messageOrange,
          unselectedLabelColor: ColorUtils.darkerGray,
          indicatorColor: ColorUtils.messageOrange,
          tabs: _buildTabs(),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 21.0),
          // Add top border
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ColorUtils.lightLightGray,
                width: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Expanded _buildContent() {
    return Expanded(
      child: TabBarView(
        children: <Widget>[
          _buildContactsListView(),
          _buildUsersListView(),
          Container()
        ],
      ),
    );
  }

  Widget _buildContactsListView() {
    return widget.contacts != null
        ? Container(
            child: Scrollbar(
              child: ListView.builder(
                  itemCount: widget.contacts?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    Contact contact = widget.contacts.elementAt(index);
                    return _buildListItem(contact.displayName, contact.avatar);
                  }),
            ),
          )
        : (_permissionStatus == PermissionStatus.granted
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Text("This app requires contacts access to function.")));
  }

  ListView _buildUsersListView() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _contactsBloc.getUsers(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 2,
                child: const Align(
                    alignment: Alignment.topCenter,
                    child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error : ${snapshot.error}'));
            } else {
              return ListView(
                shrinkWrap: true,
                primary: false,
                children:
                    snapshot.data.map<Widget>((Map<String, dynamic> item) {
                  final User user = User.fromJson(item);
                  return _buildListItem(user.name, Uint8List(0));
                }).toList(),
              );
            }
          },
        );
      },
    );
  }

  Container _buildListItem(String name, Uint8List image) {
    return Container(
      margin: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: ListTile(
            leading: (image != null && image.length > 0)
                ? CircleAvatar(backgroundImage: MemoryImage(image))
                : CircleAvatar(
                    child: Text(_getInitials(name),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                    backgroundColor: ColorUtils.lightLightGray,
                  ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                      child: Text(
                    name ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Arial', fontWeight: FontWeight.bold),
                  )),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Image.asset(
                    "assets/images/ic_contacts.png",
                    height: 16.0,
                    width: 16.0,
                  ),
                )
              ],
            ),
            subtitle: Text(
              "#installer",
              style: TextStyle(color: ColorUtils.messageOrange),
            ),
          ),
        ),
      ),
    );
  }

  _getInitials(String name) {
    var n = name.split(" "), it = "", i = 0;
    int counter = n.length > 2 ? 2 : n.length;
    while (i < counter) {
      it += n[i][0];
      i++;
    }
    return (it.toUpperCase());
  }

  List<Widget> _buildTabs() {
    return <Widget>[
      Tab(
        text: Strings.all.toUpperCase(),
      ),
      Tab(
        text: Strings.lastAccessed.toUpperCase(),
      ),
      Tab(
        text: Strings.favorites.toUpperCase(),
      ),
    ];
  }
}
