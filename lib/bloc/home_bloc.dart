import 'dart:async';

import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/global_variables.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

enum NavBarItem { HOME, CONTACTS, PLUS, INBOX, ACCOUNT }

class HomeBloc {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final StreamController<NavBarItem> _navBarController =
      StreamController<NavBarItem>.broadcast();

  NavBarItem defaultItem = NavBarItem.HOME;

  Stream<NavBarItem> get itemStream => _navBarController.stream;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _navBarController.sink.add(NavBarItem.HOME);
        break;
      case 1:
        _navBarController.sink.add(NavBarItem.CONTACTS);
        break;
      case 2:
        _navBarController.sink.add(NavBarItem.PLUS);
        break;
      case 3:
        _navBarController.sink.add(NavBarItem.INBOX);
        break;
      case 4:
        _navBarController.sink.add(NavBarItem.ACCOUNT);
        break;
    }
  }

  Future<List<PubNubConversation>> getPubNubConversations() async {
    return Repository().getPubNubConversations();
  }

  void updateDeviceToken() {
    SharedPreferencesHelper.getCurrentUserId().then((currentUserId) {
      _firebaseMessaging.getToken().then((deviceToken) {
        getCurrentUserWithFirebaseId(currentUserId).then((result) {
          if (result.errors == null) {
            Repository().updateDeviceToken(currentUserId, deviceToken,
                User.fromJson(result.data['get_user']).firebaseId);
          }
        });
      });
    });
  }

  void dispose() {
    _navBarController?.close();
  }

  Future<QueryResult> getCurrentUserWithFirebaseId(String currentUserId) {
    return Repository().getCurrentUserWithFirebaseId(currentUserId);
  }

  Future<QueryResult> getCurrentUser() async {
    String userId = await getCurrentUserId();
    return Repository().getUserById(userId);
  }
}
