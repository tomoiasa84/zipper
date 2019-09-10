import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/layouts/home_page.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class SyncContactsScreen extends StatefulWidget {
  @override
  SyncContactsScreenState createState() => SyncContactsScreenState();
}

class SyncContactsScreenState extends State<SyncContactsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );

    _animationController.repeat();
    _fetchContacts();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchContacts() {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      if (status == PermissionStatus.granted)
        getContacts().then((values) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              ModalRoute.withName("/homepage"));
        });
    });
  }

  getContacts() async {
    return ContactsService.getContacts();
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
                _builtAnimatedSyncIcon(),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    Localization.of(context).getString('syncContactsMessage'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 27.5),
                  child: LinearPercentIndicator(
                    lineHeight: 2.0,
                    percent: 0.5,
                    backgroundColor: ColorUtils.lightLightGray,
                    progressColor: ColorUtils.orangeAccent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.5,
                  ),
                  child: Text(
                    '123/155 Contacts synced',
                    style:
                        TextStyle(color: ColorUtils.darkerGray, fontSize: 12.0),
                  ),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }

  AnimatedBuilder _builtAnimatedSyncIcon() {
    return new AnimatedBuilder(
      animation: _animationController,
      child: new Image.asset('assets/images/ic_sync_gray.png'),
      builder: (BuildContext context, Widget _widget) {
        return new Transform.rotate(
          angle: _animationController.value * 50.3,
          child: _widget,
        );
      },
    );
  }
}
