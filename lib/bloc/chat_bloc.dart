import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/models/UserMessage.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class ChatBloc {
  int historyStart;
  String _timestamp = "0";
  List<UserMessage> _messagesList;
  final int _numberOfMessagesToFetch = 100;
  final StreamController ctrl = StreamController();

  final _getHistoryMessagesFetcher = PublishSubject<List<UserMessage>>();
  final _sendMessageFetcher = PublishSubject<bool>();
  final _getConversationFetcher = PublishSubject<PubNubConversation>();
  final _createConversationFetcher = PublishSubject<PubNubConversation>();


  Observable<List<UserMessage>> get getHistoryMessagesObservable =>
      _getHistoryMessagesFetcher.stream;

  Observable<bool> get sendMessageObservable => _sendMessageFetcher.stream;

  Observable<PubNubConversation> get getConversationObservable =>
      _getConversationFetcher.stream;

  Observable<PubNubConversation> get createConversationObservable =>
      _createConversationFetcher.stream;

  Future<String> uploadPic(File image) async {
    return await Repository().uploadPic(image);
  }

    getHistoryMessages(String channelName) async {
    var response = await Repository().getHistoryMessages(
        channelName, historyStart, _numberOfMessagesToFetch);

    if (response.statusCode == 200) {
      _addHistoryMessagesToList(response);
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    if (!_getHistoryMessagesFetcher.isClosed) {
      _getHistoryMessagesFetcher.sink.add(_messagesList);
    }
  }

  sendMessage(String channelId, PnGCM pnGCM) async {
    bool result = await Repository().sendMessage(channelId, pnGCM);
    if (!_sendMessageFetcher.isClosed) {
      _sendMessageFetcher.sink.add(result);
    }
  }

  void subscribeToChannel(String channelName, String currentUserId) async {
    return Repository()
        .subscribeToChannel(channelName, currentUserId, _timestamp)
        .then((response) {
      if (response.statusCode == 200) {
        var myString = response.body.substring(response.body.length - 19);
        _timestamp = myString.substring(0, myString.length - 2);
        _addMessageToList(response);
        subscribeToChannel(channelName, currentUserId);
      } else {
        print("Subscribe request failed with status: ${response.body}.");
      }
    }).catchError((error) {});
  }

  getConversation(String conversationId) async {
    PubNubConversation result =
        await Repository().getConversation(conversationId);
    if (!_getConversationFetcher.isClosed) {
      _getConversationFetcher.sink.add(result);
    }
  }

  createConversation(User user) async {
    PubNubConversation result = await Repository().createConversation(user);
    if (!_createConversationFetcher.isClosed) {
      _createConversationFetcher.sink.add(result);
    }
  }

  void _addMessageToList(http.Response response) {
    List<dynamic> messageListenerResponse = convert.jsonDecode(response.body);
    List<dynamic> messagesList = messageListenerResponse[0];

    if (messagesList.length > 0) {
      PnGCM pnGCM = PnGCM.fromJson(messagesList[0]);
      UserMessage message = pnGCM.wrappedMessage.message;
      ctrl.sink.add(message);
    }
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
    ctrl.close();
    _getHistoryMessagesFetcher.close();
    _createConversationFetcher.close();
    _sendMessageFetcher.close();
    _getConversationFetcher.close();
  }
}
