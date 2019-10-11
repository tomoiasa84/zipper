import 'dart:async';

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

enum NavBarItem { HOME, CONTACTS, PLUS, INBOX, ACCOUNT }

class HomeBloc {
  Repository _repository = Repository();

  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  final http.Client _pubNubClient = new http.Client();
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

  void subscribeToAllChannels() async {
    _firebaseMessaging.getToken().then((deviceId) {
      _getListOfIdsFromBackend().then((listOfIds) async {
        var channels = getStringOfChannelIds(listOfIds);
        var url =
            "http://ps.pndsn.com/v1/push/sub-key/$_subscribeKey/devices/$deviceId?add=$channels&type=gcm";

        var response = await _pubNubClient.get(url);

        if (response.statusCode == 200) {
          print('Succesfully subscribed to all channels');
        } else {
          print("Request failed with status: ${response.statusCode}.");
        }
      });
    });
  }

  Future<List<ConversationModel>> _getListOfIdsFromBackend() async {
    var conversationsList = await _repository.getListOfIdsFromBackend();

    return conversationsList;
  }

  void dispose() {
    _navBarController?.close();
  }
}
