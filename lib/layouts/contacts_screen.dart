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
  void initState() {
    _listenForPermissionStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              Strings.contacts,
              style: TextStyle(fontFamily: 'Arial'),
            ),
            centerTitle: true,
          ),
          body: DefaultTabController(
              length: 3,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      // Tab Bar
                      new TabBar(
                        labelStyle: TextStyle(fontFamily: "Arial"),
                        isScrollable: true,
                        labelColor: ColorUtils.messageOrange,
                        unselectedLabelColor: ColorUtils.darkerGray,
                        indicatorColor: ColorUtils.messageOrange,
                        tabs: _buildTabs(),
                      ),
                      // Border
                      Container(
                        // Negative padding
                        margin: const EdgeInsets.symmetric(horizontal: 21.0),
                        transform: Matrix4.translationValues(0.0, -2.6, 0.0),
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
                  ),
                  Expanded(
//                    child: widget.contacts != null
//                        ? Container(
//                            child: Scrollbar(
//                              child: _buildContactsListView(),
//                            ),
//                          )
//                        : (_permissionStatus == PermissionStatus.granted
//                            ? Center(
//                                child: CircularProgressIndicator(),
//                              )
//                            : Center(
//                                child: Text(
//                                    "This app requires contacts access to function."))),
                    child: TabBarView(
                      children: <Widget>[
                        _buildContactsListView(),
                        _buildUsersListView(),
                        Container()
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }

  ListView _buildUsersListView() {
    return ListView.builder(
      itemCount: 2,
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
              return _buildPage(snapshot.data);
            }
          },
        );
      },
    );
  }

  ListView _buildContactsListView() {
    return ListView.builder(
        itemCount: widget.contacts.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = widget.contacts.elementAt(index);
          return _buildListItem(contact.displayName);
        });
  }

  Container _buildListItem(String name) {
    return Container(
      margin: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.person),
          title: Text(name ?? ""),
        ),
      ),
    );
  }

  Widget _buildPage(List<Map<String, dynamic>> page) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      children: page.map<Widget>((Map<String, dynamic> item) {
        final User user = User.fromJson(item);
        return _buildListItem(user.name);
      }).toList(),
    );
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

//class EpisodesCard extends StatelessWidget {
//  const EpisodesCard({Key key, this.episode}) : super(key: key);
//
//  final User episode;
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//      padding: const EdgeInsets.all(8),
//      decoration: BoxDecoration(
//        shape: BoxShape.rectangle,
//        borderRadius: BorderRadius.circular(8.0),
//        boxShadow: const <BoxShadow>[
//          BoxShadow(
//            color: Colors.black12,
//            blurRadius: 8.0,
//            offset: Offset(0.0, 8.0),
//          ),
//        ],
//      ),
//      child: Column(
//        children: <Widget>[
//          Text(
//            episode.name,
//            style: const TextStyle(
//                color: Colors.white70,
//                fontSize: 18,
//                fontWeight: FontWeight.bold),
//          ),
//          const SizedBox(height: 4),
//          Text(
//            episode.name,
//            maxLines: 1,
//            overflow: TextOverflow.ellipsis,
//            style: const TextStyle(
//                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//          ),
//          const SizedBox(height: 8),
//          Text(
//            episode.name,
//            style: const TextStyle(color: Colors.white70, fontSize: 14),
//          ),
//        ],
//      ),
//    );
//  }
//}
