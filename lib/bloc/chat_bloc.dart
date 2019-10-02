import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:http/http.dart' as http;

class ChatBloc {
  int historyStart;
  String _timestamp = "0";
  List<UserMessage> _messagesList;
  Repository _repository = Repository();
  final int _numberOfMessagesToFetch = 100;
  final StreamController ctrl = StreamController();

  void subscribeToPushNotifications(String channelId) async {
    _repository.subscribeToPushNotifications(channelId);
  }

  Future<String> uploadPic(File image) async {
    return await _repository.uploadPic(image);
  }

  Future<List<UserMessage>> getHistoryMessages(String channelName) async {
    var response = await _repository.getHistoryMessages(
        channelName, historyStart, _numberOfMessagesToFetch);

    if (response.statusCode == 200) {
      _addHistoryMessagesToList(response);
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return _messagesList;
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    return await _repository.sendMessage(channelId, pnGCM);
  }

  void subscribeToChannel(String channelName, String currentUserId) async {
    var response = await _repository.subscribeToChannel(
        channelName, currentUserId, _timestamp);

    if (response.statusCode == 200) {
      var myString = response.body.substring(response.body.length - 19);
      _timestamp = myString.substring(0, myString.length - 2);
      await _addMessageToList(response);
      subscribeToChannel(channelName, currentUserId);
    } else {
      print("Subscribe request failed with status: ${response.body}.");
    }
  }

  Future<PubNubConversation> getConversation(String conversationId) async {
    return _repository.getConversation(conversationId);
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }

  Future _addMessageToList(http.Response response) {
    List<dynamic> messageListenerResponse = convert.jsonDecode(response.body);
    List<dynamic> messagesList = messageListenerResponse[0];

    if (messagesList.length > 0) {
      PnGCM pnGCM = PnGCM.fromJson(messagesList[0]);
      UserMessage message = pnGCM.wrappedMessage.message;
      ctrl.sink.add(message);
      return ctrl.sink.done;
    }
    return ctrl.sink.done;
  }

  void _addHistoryMessagesToList(http.Response response) {
    List<dynamic> responseList = convert.jsonDecode(response.body);
    List<dynamic> messagesList = responseList[0];
    historyStart = responseList[1];
    _messagesList = List();

    for (var item in messagesList) {
      PnGCM pnGCM = PnGCM.fromJson(item);
      UserMessage message = pnGCM.wrappedMessage.message;
      _messagesList.add(message);
    }
  }

  bool stopFetchingMessages() {
    if (_messagesList != null) {
      return _messagesList.length < _numberOfMessagesToFetch;
    } else {
      return false;
    }
  }

  void dispose() {
    _repository.dispose();
    ctrl.close();
  }
}
