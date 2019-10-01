import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _arePushNotificationsAllowed = false;
  bool _areMessageNotificationsAllowed = false;
  bool _areRecommendSearchNotificationsAllowed = false;

  @override
  void initState() {
    getSettings();
    super.initState();
  }

  Future<void> getSettings() async {
    SharedPreferencesHelper.arePushNotificationAllowed().then((value) {
      setState(() {
        _arePushNotificationsAllowed = value;
      });
    });
    SharedPreferencesHelper.areMessageNotificationAllowed().then((value) {
      setState(() {
        _areMessageNotificationsAllowed = value;
      });
    });
    SharedPreferencesHelper.areRecommendsSearchNotificationAllowed()
        .then((value) {
      setState(() {
        _areRecommendSearchNotificationsAllowed = value;
      });
    });
  }

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
        child: _buildGeneralSettingsCard()
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
                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    activeColor: ColorUtils.orangeAccent,
                    value: _arePushNotificationsAllowed,
                    onChanged: (value) {
                      SharedPreferencesHelper.setPushNotificationAllowed(value)
                          .then((_) {
                        _arePushNotificationsAllowed = value;
                      });
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Localization.of(context).getString('messageNotification')),
                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    activeColor: ColorUtils.orangeAccent,
                    value: _areMessageNotificationsAllowed,
                    onChanged: (value) {
                      SharedPreferencesHelper.setMessageNotificationAllowed(
                              value)
                          .then((_) {
                        _areMessageNotificationsAllowed = value;
                      });
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(Localization.of(context)
                      .getString('recommendSearchNotification')),
                ),
                Flexible(
                  flex: 1,
                  child: Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      activeColor: ColorUtils.orangeAccent,
                      value: _areRecommendSearchNotificationsAllowed,
                      onChanged: (value) {
                        SharedPreferencesHelper
                                .setRecommendsSearchNotificationAllowed(value)
                            .then((_) {
                          _areRecommendSearchNotificationsAllowed = value;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
