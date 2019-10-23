import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/bloc/share_selected_bloc.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class ShareSelectedContactsScreen extends StatefulWidget {
  final List<UnjoinedContactsModel> unjoinedContacts;
  final List<Contact> existingUsers;
  final String countryCode;

  const ShareSelectedContactsScreen(
      {Key key, this.unjoinedContacts, this.countryCode, this.existingUsers})
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

    _bloc.loadContacts(phoneContactsToBeLoaded).then((result) {
    });
    _bloc.loadConnections(_generateExistingUsers()).then((result) {
    });
    super.initState();
  }

  List<String> _generateContactsToBeLoaded() {
    List<String> phoneContactsToBeLoaded = [];
    widget.unjoinedContacts.forEach((contact) {
      if (contact.selected) {
        if (contact.contact.phones != null &&
            contact.contact.phones.toList().isNotEmpty) {
          if (contact.contact.phones
              .toList()
              .elementAt(0)
              .value
              .toString()
              .startsWith("+")) {
            phoneContactsToBeLoaded.add(
                contact.contact.phones.toList().elementAt(0).value.toString());
          } else {
            phoneContactsToBeLoaded.add(widget.countryCode +
                contact.contact.phones.toList().elementAt(0).value.toString());
          }
        }
      }
    });
    return phoneContactsToBeLoaded;
  }

  List<String> _generateExistingUsers() {
    List<String> existingUsers = [];
    widget.existingUsers.forEach((contact) {
      if (contact.phones != null && contact.phones.toList().isNotEmpty) {
        if (contact.phones
            .toList()
            .elementAt(0)
            .value
            .toString()
            .startsWith("+")) {
          existingUsers
              .add(contact.phones.toList().elementAt(0).value.toString());
        } else {
          existingUsers.add(widget.countryCode +
              contact.phones.toList().elementAt(0).value.toString());
        }
      }
    });
    return existingUsers;
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
