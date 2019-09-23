import 'package:contractor_search/bloc/sync_contacts_model.dart';
import 'package:contractor_search/layouts/share_selected_screen.dart';
import 'package:contractor_search/layouts/unjoined_contacts_screen.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';

import 'joined_contacts_screen.dart';

class SyncResultsScreen extends StatefulWidget {
  final SyncContactsModel syncResult;

  const SyncResultsScreen({Key key, this.syncResult}) : super(key: key);

  @override
  SyncResultsScreenState createState() => SyncResultsScreenState();
}

class SyncResultsScreenState extends State<SyncResultsScreen> {
  List<UnjoinedContactsModel> unjoinedContacts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  @override
  void initState() {
    unjoinedContacts = widget.syncResult.unjoinedContacts;
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(Localization.of(context).getString("syncResults"),
          style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }

  Container _buildBody() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              Localization.of(context).getString("usersFoundInYourPhone"),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildPublicTagsCard(),
          _buildUntaggedContactsCard(),
          _buildShareButton()
        ],
      ),
    );
  }

  Card _buildPublicTagsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 21.0),
        child: Row(
          children: <Widget>[
            _buildCardTitle(
                Localization.of(context).getString("existingUsers"),
                widget.syncResult.existingUsers.length.toString() +
                    " " +
                    Localization.of(context).getString("users").toLowerCase()),
            _buildForwardArrow(() {
              _navigateAndDisplayJoinedUsers();
            })
          ],
        ),
      ),
    );
  }

  Card _buildUntaggedContactsCard() {
    int selectedContacts = 0;
    unjoinedContacts.forEach((item) {
      if (item.selected) {
        selectedContacts++;
      }
    });
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 21.0),
        child: Row(
          children: <Widget>[
            _buildCardTitle(
                Localization.of(context).getString("unjoinedContacts"),
                selectedContacts.toString() +
                    " " +
                    Localization.of(context)
                        .getString("contacts")
                        .toLowerCase()),
            _buildForwardArrow(() {
              _navigateAndDisplayUnjoinedUsers();
            })
          ],
        ),
      ),
    );
  }

  Future _navigateAndDisplayUnjoinedUsers() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UnjoinedContactsScreen(
                  unjoinedContacts: widget.syncResult.unjoinedContacts,
                )));
    setState(() {
      unjoinedContacts = widget.syncResult.unjoinedContacts;
    });
  }

  void _navigateAndDisplayJoinedUsers() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => JoinedContactsScreen(
                  joinedContacts: widget.syncResult.existingUsers,
                )));
  }

  Padding _buildCardTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: ColorUtils.orangeAccent),
          )
        ],
      ),
    );
  }

  Expanded _buildForwardArrow(Function onTapAction) {
    return Expanded(
      child: GestureDetector(
        onTap: onTapAction,
        child: Container(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.arrow_forward,
            color: ColorUtils.orangeAccent,
          ),
        ),
      ),
    );
  }

  Container _buildShareButton() {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(top: 89.0),
      child: RaisedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ShareSelectedContactsScreen(
                        unjoinedContacts: widget.syncResult.unjoinedContacts,
                        countryCode: widget.syncResult.countryCode,
                      )),
              ModalRoute.withName("/homepage"));
        },
        color: ColorUtils.orangeAccent,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
        ),
        child: Text(
          Localization.of(context).getString("shareSelected"),
          style: TextStyle(
            color: ColorUtils.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
