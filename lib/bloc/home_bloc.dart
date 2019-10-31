import 'dart:async';

import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/shared_preferences_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

enum NavBarItem { HOME, CONTACTS, PLUS, INBOX, ACCOUNT }

class HomeBloc {
  Repository _repository = Repository();
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

  void updateDeviceToken() {
    SharedPreferencesHelper.getCurrentUserId().then((currentUserId) {
      _firebaseMessaging.getToken().then((deviceToken) {
        _repository.updateDeviceToken(currentUserId, deviceToken);
      });
    });
  }

  void dispose() {
    _navBarController?.close();
  }

  Future<QueryResult> getCurrentUser() async {
    String userId = await getCurrentUserId();
    return _repository.getUserById(userId);
  }
}
