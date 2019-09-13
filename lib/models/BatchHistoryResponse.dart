import 'dart:collection';

import 'package:contractor_search/models/Conversation.dart';
import 'package:contractor_search/models/LastMessage.dart';
import 'package:contractor_search/models/Message.dart';

class BatchHistoryResponse {
  LinkedHashMap _channels;
  int _status;
  bool _error;
  String _errorMessage;

  BatchHistoryResponse(this._channels);

  LinkedHashMap get channels => _channels;

  int get status => _status;

  bool get error => _error;

  String get errorMessage => _errorMessage;

  List<Conversation> get conversations => getConversations(_channels);

  BatchHistoryResponse.fromJson(Map<String, dynamic> json)
      : _channels = json['channels'],
        _status = json['status'],
        _error = json['error'],
        _errorMessage = json['error_message'];

  List<Conversation> getConversations(_channels) {
    var list = List<Conversation>();
    _channels.forEach((k, v) => list.add(_mapConversation(k, v)));
    list.sort((a, b) {
      return b.lastMessage.timeToken.compareTo(a.lastMessage.timeToken);
    });
    return list;
  }

  Conversation _mapConversation(dynamic k, dynamic v) {
    LinkedHashMap hashMap = v[0];
    LinkedHashMap messageMap = hashMap['message'];

    LastMessage lastMessage = LastMessage(
        hashMap['timetoken'], Message(messageMap['message'], null, null));

    return Conversation(k.toString(), k.toString(), "", "", lastMessage);
  }
}
