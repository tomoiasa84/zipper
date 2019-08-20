import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  @override
  ContactsScreenState createState() {
    return ContactsScreenState();
  }
}

class ContactsScreenState extends State<ContactsScreen> {
  Iterable<Contact> _contacts;

  @override
  void initState() {
    refreshContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: _contacts != null
            ? Container(
                margin: const EdgeInsets.all(12.0),
                child: ListView.builder(
                    itemCount: _contacts?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      Contact c = _contacts.elementAt(index);
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(c.displayName ?? ""),
                      );
                    }),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  refreshContacts() async {
    var contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }
}
