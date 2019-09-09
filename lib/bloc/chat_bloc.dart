import 'dart:convert' as convert;

import 'package:contractor_search/models/Message.dart';
import 'package:contractor_search/models/MessageResponse.dart';
import 'package:http/http.dart' as http;

class ChatBloc {
  final String _publishKey = "pub-c-202b96b5-ebbe-4a3a-94fd-dc45b0bd382e";
  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  var _client = new http.Client();
  String _timestamp = "0";

  Future<Null> getHistoryMessages(String channelName) async {
    var url =
        "$_baseUrl/v2/history/sub-key/$_subscribeKey/channel/$channelName";
    var response = await _client.get(url);

    if (response.statusCode == 200) {
      Map messagesResponse = convert.jsonDecode(response.body);
      //var historyMessages = MessageResponse.fromJson(messagesResponse);
      print(messagesResponse);
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
  }

  Future<Null> sendMessage(String channelName, Message message) async {
    var encodedMessage = convert.jsonEncode(message.toJson());
    var url =
        "$_baseUrl/publish/$_publishKey/$_subscribeKey/0/$channelName/myCallback/$encodedMessage";

    var response = await _client.get(url);
    if (response.statusCode == 200) {
      print("Message added");
    } else {
      print("Request failed with status: ${response.body}.");
    }
  }

  void subscribeToChannel(String channelName) async {
    var url =
        "$_baseUrl/subscribe/$_subscribeKey/$channelName/0/$_timestamp?uuid=12345";
    var response = await _client.get(url);
    if (response.statusCode == 200) {
      var myString = response.body.substring(response.body.length - 19);
      print (response.body);
      print(myString.substring(0, myString.length - 2));
      _timestamp = myString.substring(0, myString.length - 2);
      subscribeToChannel(channelName);
    } else {
      print("Subscribe request failed with status: ${response.body}.");
    }
  }

  void dispose() {
    _client.close();
  }
}
