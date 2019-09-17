import 'package:contacts_service/contacts_service.dart';
import 'package:contractor_search/bloc/sync_contacts_bloc.dart';
import 'package:contractor_search/layouts/sync_results_screen.dart';
import 'package:contractor_search/model/contact_model.dart';
import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
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
  SyncContactsBloc _syncContactsBloc;

  String countryCode;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );

    _animationController.repeat();
    _syncContactsBloc = SyncContactsBloc();
    _loadContacts();
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

  void _loadContacts() {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      if (status == PermissionStatus.granted) {
        getCurrentUserId().then((userId) {
          _syncContactsBloc.getCurrentUser(userId).then((result) {
            if (result.errors == null) {
               countryCode = User.fromJson(result.data['get_user'])
                  .phoneNumber
                  .substring(0, 2);
              _syncContactsBloc.getContacts().then((contactsResult) {
                List<String> phoneContacts = [];
                contactsResult.forEach((item) {
                  if (item.phones != null && item.phones.toList().isNotEmpty) {
                    if (item.phones
                        .toList()
                        .elementAt(0)
                        .value
                        .toString()
                        .startsWith("+")) {
                      phoneContacts
                          .add(item.phones.toList().elementAt(0).value);
                    } else {
                      phoneContacts.add(countryCode +
                          item.phones.toList().elementAt(0).value);
                    }
                  }
                });
                _syncContactsBloc
                    .checkContacts(phoneContacts.toSet().toList())
                    .then((result) {
                  if (result.errors == null) {
                    List<UnjoinedContactsModel> unjoinedContacts = [];
                    List<Contact> joinedContacts = [];
                    final List<Map<String, dynamic>> checkContactsResult =
                        result.data['check_contacts']
                            .cast<Map<String, dynamic>>();
                    checkContactsResult.forEach((item) {
                      ContactModel contactModel = ContactModel.fromJson(item);

                      Contact contact = contactsResult.firstWhere(
                          (contact) => (contact.phones != null &&
                                  contact.phones.toList().isNotEmpty)
                              ? (contact.phones.toList().elementAt(0).value ==
                                      contactModel.number ||
                                  countryCode +
                                          contact.phones
                                              .toList()
                                              .elementAt(0)
                                              .value ==
                                      contactModel.number)
                              : false,
                          orElse: () => null);
                      if (contact != null) if (contactModel.exists) {
                        joinedContacts.add(contact);
                      } else {
                        unjoinedContacts.add(UnjoinedContactsModel(contact, true));
                      }
                    });

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SyncResultsScreen(
                                unjoinedContacts: unjoinedContacts,
                                joinedContacts: joinedContacts,
                            countryCode: countryCode,)),
                        ModalRoute.withName("/homepage"));
                  }
                });
              });
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
