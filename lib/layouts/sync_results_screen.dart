import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class SyncResultsScreen extends StatefulWidget {
  @override
  SyncResultsScreenState createState() => SyncResultsScreenState();
}

class SyncResultsScreenState extends State<SyncResultsScreen> {
  bool _publicTags = true;
  bool _untaggedContacts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(Localization.of(context).getString("syncResults"),
          style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  ModalRoute.withName("/homepage"));
            },
            child: Text(Localization.of(context).getString("skip"),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColorUtils.orangeAccent)),
          ),
        )
      ],
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
              Localization.of(context).getString("tagsFoundInYourPhone"),
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
            GestureDetector(
              onTap: () {
                setState(() {
                  _publicTags = !_publicTags;
                });
              },
              child: Icon(
                Icons.check_box,
                color: _publicTags
                    ? ColorUtils.orangeAccent
                    : ColorUtils.lightLightGray,
              ),
            ),
            _buildCardTitle(
                Localization.of(context).getString("publicTags"), "100 tags"),
            _buildForwardArrow(() {}),
          ],
        ),
      ),
    );
  }

  Card _buildUntaggedContactsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 21.0),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  _untaggedContacts = !_untaggedContacts;
                });
              },
              child: Icon(
                Icons.check_box,
                color: _untaggedContacts
                    ? ColorUtils.orangeAccent
                    : ColorUtils.lightLightGray,
              ),
            ),
            _buildCardTitle(
                Localization.of(context).getString("untaggedContacts"),
                "55 contacts"),
            _buildForwardArrow(() {})
          ],
        ),
      ),
    );
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
          if (_publicTags || _untaggedContacts) {}
        },
        color: (_publicTags || _untaggedContacts)
            ? ColorUtils.orangeAccent
            : ColorUtils.lightLightGray,
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
