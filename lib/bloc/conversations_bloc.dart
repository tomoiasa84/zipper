import 'dart:async';
import 'dart:convert' as convert;

import 'package:contractor_search/models/BatchHistoryResponse.dart';
import 'package:contractor_search/models/Conversation.dart';
import 'package:http/http.dart' as http;

class ConversationsBloc {
  final String _subscribeKey = "sub-c-e742fad6-c8a5-11e9-9d00-8a58a5558306";
  final String _baseUrl = "https://ps.pndsn.com";
  final http.Client _client = new http.Client();
  final StreamController ctrl = StreamController();

  Future<List<Conversation>> getConversations() async {
    return _getListOfIdsFromBackend().then((listOfIds) async {
      var channels = _getStringOfChannelIds(listOfIds);
      var url =
          "$_baseUrl/v3/history/sub-key/$_subscribeKey/channel/$channels?max=1";

      var response = await _client.get(url);

      if (response.statusCode == 200) {
        return _addConversationsToList(response);
      } else {
        print("Request failed with status: ${response.statusCode}.");
        return List<Conversation>();
      }
    });
  }

  Future<List<String>> _getListOfIdsFromBackend() async {
    return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];
  }

  String _getStringOfChannelIds(List<String> listOfConversation) {
    return listOfConversation
        .toString()
        .substring(1, listOfConversation.toString().length - 1)
        .replaceAll(" ", "");
  }

  List<Conversation> _addConversationsToList(http.Response response) {
    BatchHistoryResponse batchHistoryResponse =
        BatchHistoryResponse.fromJson(convert.jsonDecode(response.body));

    return batchHistoryResponse.conversations;
  }

  void dispose() {
    _client.close();
    ctrl.close();
  }
}
