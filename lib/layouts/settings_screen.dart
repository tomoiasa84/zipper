import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _arePushNotificationsAllowed = false;
  bool _areMessageNotificationsAllowed = false;
  bool _areRecommendSearchNotificationsAllowed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString('settings'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildGeneralSettingsCard(),
            _buildPrivacySettingsCard(),
          ],
        ),
      ),
    );
  }

  Card _buildGeneralSettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 24.0, left: 16.0, bottom: 16.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Localization.of(context).getString('generalSettings'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Localization.of(context)
                    .getString('allowPushNotifications')),
                Switch(
                  activeColor: ColorUtils.orangeAccent,
                  value: _arePushNotificationsAllowed,
                  onChanged: (value) {
                    _arePushNotificationsAllowed = value;
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Localization.of(context).getString('messageNotification')),
                Switch(
                  activeColor: ColorUtils.orangeAccent,
                  value: _areMessageNotificationsAllowed,
                  onChanged: (value) {
                    _areMessageNotificationsAllowed = value;
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Localization.of(context)
                    .getString('recommendSearchNotification')),
                Switch(
                  activeColor: ColorUtils.orangeAccent,
                  value: _areRecommendSearchNotificationsAllowed,
                  onChanged: (value) {
                    _areRecommendSearchNotificationsAllowed = value;
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _buildPrivacySettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Localization.of(context).getString('privacySettings'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Text(
                      Localization.of(context)
                          .getString('whoCanSeeYourProfile'),
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          Localization.of(context).getString('everyone'),
                          style: TextStyle(color: ColorUtils.textGray),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Text(
                      Localization.of(context)
                          .getString('whoCanSendYouFriendRequest'),
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          Localization.of(context).getString('friendsOf'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: ColorUtils.textGray),
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Text(
                      Localization.of(context)
                          .getString('whoCanSendYouMessage'),
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          Localization.of(context).getString('everyone'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: ColorUtils.textGray),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
