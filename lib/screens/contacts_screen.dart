import 'package:contacts_service/contacts_service.dart';
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
        child: widget.contacts != null
            ? Container(
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount: widget.contacts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact c = widget.contacts.elementAt(index);
                        return Container(
                          margin:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Card(
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text(c.displayName ?? ""),
                            ),
                          ),
                        );
                      }),
                ),
              )
            : (_permissionStatus == PermissionStatus.granted
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: Text(
                        "This app requires contacts access to function."))));
  }
}
