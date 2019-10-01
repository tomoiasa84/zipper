import 'dart:async';
import 'dart:convert' as convert;

import 'package:contractor_search/model/conversation_model.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/models/BatchHistoryResponse.dart';
import 'package:contractor_search/models/PnGCM.dart';
import 'package:contractor_search/models/PubNubConversation.dart';
import 'package:contractor_search/persistance/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class SendInChatBloc {
  Repository _repository = Repository();

  final String _publishKey = "pub-c-202b96b5-ebbe-4a3a-94fd-dc45b0bd382e";
  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  final http.Client _pubnubClient = new http.Client();
  final StreamController ctrl = StreamController();
  List<ConversationModel> _conversationsList;

  Future<QueryResult> getUsers() async {
    return _repository.getUsers();
  }

  Future<List<PubNubConversation>> getPubNubConversations() async {
    return _getListOfIdsFromBackend().then((listOfIds) async {
      var channels = _getStringOfChannelIds(listOfIds);
      var url =
          "$_baseUrl/v3/history/sub-key/$_subscribeKey/channel/$channels?max=1";

      var response = await _pubnubClient.get(url);

      if (response.statusCode == 200) {
        return _addConversationsToList(response);
      } else {
        print("Request failed with status: ${response.statusCode}.");
        return List<PubNubConversation>();
      }
    });
  }

  Future<List<ConversationModel>> _getListOfIdsFromBackend() async {
    _conversationsList = await _repository.getListOfIdsFromBackend();

    return _conversationsList;
  }

  String _getStringOfChannelIds(List<ConversationModel> listOfConversation) {
    String channelIds = "";

    for (var item in listOfConversation) {
      channelIds = channelIds + item.id.toString() + ",";
    }

    return channelIds;
  }

  List<PubNubConversation> _addConversationsToList(http.Response response) {
    BatchHistoryResponse batchHistoryResponse =
        BatchHistoryResponse.fromJson(convert.jsonDecode(response.body));

    var pubNubConversationsList = batchHistoryResponse.conversations;

    for (var pubNubConversation in pubNubConversationsList) {
      var conversation = _conversationsList
          .firstWhere((con) => con.id == pubNubConversation.id);
      pubNubConversation.user1 = conversation.user1;
      pubNubConversation.user2 = conversation.user2;
    }
    return pubNubConversationsList;
  }

  Future<PubNubConversation> createConversation(User user) async {
    return await _repository.createConversation(user);
  }

  Future<bool> sendMessage(String channelId, PnGCM pnGCM) async {
    var encodedMessage = convert.jsonEncode(pnGCM.toJson());
    var url =
        "$_baseUrl/publish/$_publishKey/$_subscribeKey/0/$channelId/myCallback/$encodedMessage";

    var response = await _pubnubClient.get(url);
    if (response.statusCode == 200) {
      return true;
    } else {
      print("Request failed with status: ${response.body}.");
      return false;
    }
  }
}
