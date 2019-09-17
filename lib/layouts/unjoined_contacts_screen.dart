import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class UnjoinedContactsScreen extends StatefulWidget {
  final List<UnjoinedContactsModel> unjoinedContacts;

  const UnjoinedContactsScreen({Key key, this.unjoinedContacts})
      : super(key: key);

  @override
  UnjoinedContactsScreenState createState() => UnjoinedContactsScreenState();
}

class UnjoinedContactsScreenState extends State<UnjoinedContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 24.0),
              child: Text(
                Localization.of(context)
                    .getString("addTagsToPromoteYourFriends"),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ),
            Expanded(
              child: _buildUntaggedContactsList(),
            )
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString("unjoinedContacts"),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      centerTitle: true,
      leading: buildBackButton(() {
        Navigator.pop(context, true);
      }),
    );
  }

  ListView _buildUntaggedContactsList() {
    return ListView.builder(
        itemCount: widget.unjoinedContacts.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildListItem(widget.unjoinedContacts.elementAt(index));
        });
  }

  Card _buildListItem(UnjoinedContactsModel unjoinedContact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Text(getInitials(unjoinedContact.contact.displayName),
                  style: TextStyle(color: ColorUtils.darkerGray)),
              backgroundColor: ColorUtils.lightLightGray,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    unjoinedContact.contact.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Add #",
                    style: TextStyle(color: ColorUtils.orangeAccent),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      unjoinedContact.selected = !unjoinedContact.selected;
                    });
                  },
                  child: Icon(
                    Icons.check_box,
                    color: unjoinedContact.selected
                        ? ColorUtils.orangeAccent
                        : ColorUtils.lightLightGray,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
