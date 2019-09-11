import 'dart:async';
import 'dart:convert' as convert;

import 'package:contractor_search/models/Message.dart';
import 'package:http/http.dart' as http;

class ChatBloc {
  final String _publishKey = "pub-c-202b96b5-ebbe-4a3a-94fd-dc45b0bd382e";
  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  final http.Client _client = new http.Client();
  final StreamController ctrl = StreamController();
  final List<Message> _messagesList = new List();
  final int _messagesCount = 30;
  int _historyStart;
  String _timestamp = "0";

  Future<List<Message>> getHistoryMessages(String channelName) async {
    var url;

    if (_historyStart == 0) {
      return List();
    }

    if (_historyStart == null) {
      url =
          "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName?count=$_messagesCount";
    } else {
      url =
          "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName?count=$_messagesCount&start=$_historyStart";
    }

    var response = await _client.get(url);

    if (response.statusCode == 200) {
      _addHistoryMessagesToList(response);
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return _messagesList;
  }

  void _addHistoryMessagesToList(http.Response response) {
    List<dynamic> responseList = convert.jsonDecode(response.body);
    List<dynamic> messagesList = responseList[0];
    _historyStart = responseList[1];

    for (var item in messagesList) {
      Message message = Message.fromJson(item);
      _messagesList.add(message);
    }
  }

  void subscribeToChannel(String channelName) async {
    var url =
        "$_baseUrl/subscribe/$_subscribeKey/$channelName/0/$_timestamp?uuid=12345";
    var response = await _client.get(url);

    if (response.statusCode == 200) {
      var myString = response.body.substring(response.body.length - 19);
      _timestamp = myString.substring(0, myString.length - 2);
      _addMessageToList(response);
      subscribeToChannel(channelName);
    } else {
      print("Subscribe request failed with status: ${response.body}.");
    }
  }

  void _addMessageToList(http.Response response) {
    List<dynamic> messageListenerResponse = convert.jsonDecode(response.body);
    List<dynamic> messagesList = messageListenerResponse[0];

    if (messagesList.length > 0) {
      Message message = Message.fromJson(messagesList[0]);
      ctrl.sink.add(message);
    }
  }

  void sendMessage(String channelName, Message message) async {
    var encodedMessage = convert.jsonEncode(message.toJson());
    var url =
        "$_baseUrl/publish/$_publishKey/$_subscribeKey/0/$channelName/myCallback/$encodedMessage";

    var response = await _client.get(url);
    if (response.statusCode != 200) {
      print("Request failed with status: ${response.body}.");
    }
  }

  void dispose() {
    _client.close();
    ctrl.close();
  }
}
