import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class JoinedContactsScreen extends StatefulWidget {
  final List<Contact> joinedContacts;

  const JoinedContactsScreen({Key key, this.joinedContacts}) : super(key: key);

  @override
  JoinedContactsScreenState createState() => JoinedContactsScreenState();
}

class JoinedContactsScreenState extends State<JoinedContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: _buildUntaggedContactsList(),
          )
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString("existingUsers"),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      centerTitle: true,
      leading: buildBackButton(Icons.arrow_back,() {
        Navigator.pop(context, true);
      }),
    );
  }

  ListView _buildUntaggedContactsList() {
    return ListView.builder(
        itemCount: widget.joinedContacts.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.only(
                  top: (index == 0) ? 24.0 : 0.0,
                  bottom:
                      (index == widget.joinedContacts.length - 1) ? 24.0 : 0.0,
                  left: 16.0,
                  right: 16.0),
              child: _buildListItem(widget.joinedContacts.elementAt(index)));
        });
  }

  Card _buildListItem(Contact contact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            (contact.avatar != null && contact.avatar.length > 0)
                ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar))
                : CircleAvatar(
                    child: Text(getInitials(contact.displayName),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                    backgroundColor: ColorUtils.lightLightGray,
                  ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  contact.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
