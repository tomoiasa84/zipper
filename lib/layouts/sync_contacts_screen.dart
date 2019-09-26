import 'package:contractor_search/bloc/sync_contacts_bloc.dart';
import 'package:contractor_search/layouts/sync_results_screen.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/custom_dialog.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SyncContactsScreen extends StatefulWidget {
  @override
  SyncContactsScreenState createState() => SyncContactsScreenState();
}

class SyncContactsScreenState extends State<SyncContactsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  SyncContactsBloc _syncContactsBloc;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );

    _animationController.repeat();
    _syncContactsBloc = SyncContactsBloc();
    _syncContacts();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> getCurrentUserId() async {
    return await SharedPreferencesHelper.getCurrentUserId();
  }

  void _syncContacts() {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      if (status == PermissionStatus.granted) {
        getCurrentUserId().then((userId) {
          _syncContactsBloc.syncContacts(userId).then((syncResult) {
            if(syncResult.error.isNotEmpty){
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: Localization.of(context).getString("error"),
                  description: syncResult.error,
                  buttonText: Localization.of(context).getString("ok"),
                ),
              );
            }
            else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SyncResultsScreen(
                            syncResult: syncResult,
                          )),
                  ModalRoute.withName("/homepage"));
            }
          });
        });
      }
    });
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
                _buildDescription(context),
                _buildLinearIndicator(),
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
        Localization.of(context).getString('syncContactsMessage'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Padding _buildLinearIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 27.5),
      child: SizedBox(
        height: 2.0,
        child: LinearProgressIndicator(
          backgroundColor: ColorUtils.lightLightGray,
          valueColor: AlwaysStoppedAnimation<Color>(ColorUtils.orangeAccent),
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
