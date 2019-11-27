import 'package:contractor_search/bloc/share_selected_bloc.dart';
import 'package:contractor_search/model/formatted_contact_model.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class ShareSelectedContactsScreen extends StatefulWidget {
  final List<UnjoinedContactsModel> unjoinedContacts;
  final List<FormattedContactModel> existingUsers;

  const ShareSelectedContactsScreen(
      {Key key, this.unjoinedContacts, this.existingUsers})
      : super(key: key);

  @override
  ShareSelectedContactsScreenState createState() =>
      ShareSelectedContactsScreenState();
}

class ShareSelectedContactsScreenState
    extends State<ShareSelectedContactsScreen> {
  ShareSelectedBloc _bloc;

  @override
  void initState() {
    _bloc = ShareSelectedBloc();
    List<String> phoneContactsToBeLoaded = _generateContactsToBeLoaded();

    _bloc.loadContacts(phoneContactsToBeLoaded);
    _bloc.loadConnections(_generateExistingUsers());
    super.initState();
  }

  List<String> _generateContactsToBeLoaded() {
    List<String> phoneContactsToBeLoaded = [];
    widget.unjoinedContacts.forEach((contact) {
      if (contact != null && contact.selected && contact.contact != null) {
        phoneContactsToBeLoaded.add(contact.contact.formattedPhoneNumber);
      }
    });
    return phoneContactsToBeLoaded;
  }

  List<String> _generateExistingUsers() {
    List<String> existingUsers = [];
    widget.existingUsers.forEach((contact) {
      if (contact != null &&
          contact.formattedPhoneNumber != null &&
          contact.formattedPhoneNumber.isNotEmpty) {
        existingUsers.add(contact.formattedPhoneNumber);
      }
    });
    return existingUsers;
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
              child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/ic_share_gray_bg.png",
                ),
                _buildDescription(context),
                _buildContinueButton(),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Container _buildDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        Localization.of(context).getString('selectedContactsWillBeShared'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _buildContinueButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: RaisedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        syncContactsFlagRequired: true,
                      )),
              ModalRoute.withName("/homepage"));
        },
        color: ColorUtils.orangeAccent,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
        ),
        child: Text(
          Localization.of(context).getString("continue"),
          style: TextStyle(
            color: ColorUtils.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
